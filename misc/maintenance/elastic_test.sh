function index_exists {
  IDX_NAME="$1"
  FATAL="$2"
  echo ""
  echo "ES Indices check - $IDX_NAME"
  echo "----------------------------"
  INDICES=$(curl -X GET http://$ES_SERVER/_cat/indices?v)
  [[ $? -ne 0 ]] && echo "ES Indices request failed\nINDICES" && exit 6

  INDEX_FOUND=$(echo "$INDICES" | grep -Po "$IDX_NAME")
  [[ -z "$INDEX_FOUND" ]] && echo "Index=$IDX_NAME not found in INDICES."
  [[ -z "$INDEX_FOUND" && ! -z "$FATAL" ]] && exit 7
}

function delete_index {
  IDX_NAME="$1"
  FATAL="$2"
  VERBOSE="$3"
  [[ ! -z "$VERBOSE" ]] && echo ""
  [[ ! -z "$VERBOSE" ]] && echo "ES Delete test index - $IDX_NAME"
  [[ ! -z "$VERBOSE" ]] && echo "--------------------------------"
  DEL_IDX=$(curl -X DELETE http://$ES_SERVER/$IDX_NAME?pretty)
  [[ $? -ne 0 ]] && echo "ES Delete test index request failed\n$DEL_IDX" && exit 6

  OK=$(echo "$DEL_IDX" | grep -Po '"acknowledged" : true')
  [[ -z "$OK" && ! -z "$VERBOSE" ]] && echo "Test index not deleted?\n$DEL_IDX"
  [[ -z "$OK" && ! -z "$FATAL" ]] && exit 10

  INDICES=$(curl -X GET http://$ES_SERVER/_cat/indices?v)
  [[ $? -ne 0 ]] && echo "Test index deletion Indices list request failed\nI$NDICES" && exit 6

  INDEX_FOUND=$(echo "$INDICES" | grep -Po "$TEST_IDX")
  [[ ! -z "$INDEX_FOUND" && ! -z "$VERBOSE" ]] && echo "Index=$TEST_IDX was supposed to be deleted."
  [[ ! -z "$INDEX_FOUND" && ! -z "$FATAL" ]] && exit 10
}

echo ""
echo "---------------------------------------"
echo "Testing Koha-Elasticsearch connectivity"
echo "---------------------------------------"
echo ""


ES_SERVER=$(xmllint --xpath "yazgfs/config/elasticsearch/server/text()" $KOHA_CONF)
ES_INDEX=$(xmllint --xpath "yazgfs/config/elasticsearch/index_name/text()" $KOHA_CONF)
TEST_IDX="kohatest"

[[ -z "$ES_SERVER" ]] && echo "\$KOHA_CONF -> yazgfs/config/elasticsearch/server is not defined" && exit 1
[[ -z "$ES_INDEX" ]]  && echo "\$KOHA_CONF -> yazgfs/config/elasticsearch/index_name is not defined" && exit 2

echo "ES_SERVER = $ES_SERVER"
echo "ES_INDEX  = $ES_INDEX"
echo ""

echo "ES Health check"
echo "---------------"
HEALTH=$(curl -X GET http://$ES_SERVER/_cat/health?v)
[[ $? -ne 0 ]] && echo "ES Health request failed:\n$HEALTH" && exit 3

echo ""
echo "ES Nodes check"
echo "--------------"
NODES=$(curl -X GET http://$ES_SERVER/_cat/nodes?v)
[[ $? -ne 0 ]] && echo "ES Nodes request failed\nNODES" && exit 4

NODES_CNT=$(echo "$NODES" | wc -l)
[[ $NODES_CNT -lt 1 ]] && echo "No ES Nodes found!" && exit 5

index_exists "$ES_INDEX"

delete_index "$TEST_IDX"

echo ""
echo "ES Create test index"
echo "--------------------"
CREATE_INDEX=$(curl -X PUT http://$ES_SERVER/$TEST_IDX?pretty -d '{
    "settings" : {
        "index" : {
            "number_of_shards" : 1,
            "number_of_replicas" : 0
        }
    }
}')
[[ $? -ne 0 ]] && echo "ES Create test index request failed\nCREATE_INDEX" && exit 6

OK=$(echo "$CREATE_INDEX" | grep -Po '"acknowledged" : true')
[[ -z "$OK" ]] && echo "Test index not created?\n$CREATE_INDEX" && exit 9

index_exists "$TEST_IDX" "is-fatal"

echo ""
echo "ES Create test document"
echo "--------------------"
CREATE_DOC=$(curl -X PUT http://$ES_SERVER/$TEST_IDX/doc/1?pretty -d '{
  "name": "Matti Meikäläinen"
}')
[[ $? -ne 0 ]] && echo "ES Create test document request failed\n$CREATE_DOC" && exit 6

OK=$(echo "$CREATE_DOC" | grep -Po '"result" : "created"')
[[ -z "$OK" ]] && echo "Test document not created?\n$CREATE_DOC" && exit 10

echo ""
echo "ES Get test document"
echo "--------------------"
GET_DOC=$(curl -X GET http://$ES_SERVER/$TEST_IDX/doc/1?pretty)
[[ $? -ne 0 ]] && echo "ES Get test document request failed\n$GET_DOC" && exit 6

OK=$(echo "$GET_DOC" | grep -Po 'Matti Meikäläinen')
[[ -z "$OK" ]] && echo "Test document not found?\n$GET_DOC" && exit 10

delete_index "$TEST_IDX" "VERBOSE"




echo ""
echo "-----------------------------------"
echo "Testing simple indexing of a record"
echo "-----------------------------------"
echo ""

SQL_RESULT=$(mysql --batch -e "SELECT MAX(biblionumber) FROM biblio")
[[ $? -ne 0 ]] && echo "ES Get a biblionumber request failed\n$SQL_RESULT" && exit 60

BIBLIONUMBER=$(echo $SQL_RESULT | grep -Po '\d+')
[[ $? -ne 0 ]] && echo "ES Extract a biblionumber failed\n$SQL_RESULT" && exit 61

if [[ ! -z $BIBLIONUMBER ]] #Index a single record to ES if records are available
then
  PINDEXING=$(perl -I$KOHA_PATH $KOHA_PATH/misc/search_tools/rebuild_elastic_search.pl -v -v --bnumber $BIBLIONUMBER -c 1)
  [[ $? -ne 0 ]] && echo "ES indexing a biblionumber failed\n$PINDEXING" && exit 63
else
  echo "... No records in Koha, skipping indexing test ..."
fi


echo "Done!"
echo "All tests pass."

#All is well
exit 0
