[%
  USE I18N;

  MACRO t(msgid) BLOCK;
    I18N.t(msgid);
  END;

  MACRO tx(msgid, vars) BLOCK;
    I18N.tx(msgid, vars);
  END;

  MACRO tn(msgid, msgid_plural, count) BLOCK;
    I18N.tn(msgid, msgid_plural, count);
  END;

  MACRO tnx(msgid, msgid_plural, count, vars) BLOCK;
    I18N.tnx(msgid, msgid_plural, count, vars);
  END;

  MACRO txn(msgid, msgid_plural, count, vars) BLOCK;
    I18N.txn(msgid, msgid_plural, count, vars);
  END;

  MACRO tp(msgctxt, msgid) BLOCK;
    I18N.tp(msgctxt, msgid);
  END;

  MACRO tpx(msgctxt, msgid, vars) BLOCK;
    I18N.tpx(msgctxt, msgid, vars);
  END;

  MACRO tnp(msgctxt, msgid, msgid_plural, count) BLOCK;
    I18N.tnp(msgctxt, msgid, msgid_plural, count);
  END;

  MACRO tnpx(msgctxt, msgid, msgid_plural, count, vars) BLOCK;
    I18N.tnpx(msgctxt, msgid, msgid_plural, count, vars);
  END;
%]
