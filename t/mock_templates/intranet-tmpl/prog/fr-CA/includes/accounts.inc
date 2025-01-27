[%- BLOCK account_type_description -%]
    [%- IF account.credit_type_code -%]
        [%- PROCESS credit_type_description credit_type = account.credit_type -%]
    [%- ELSIF account.debit_type_code -%]
        [%- PROCESS debit_type_description debit_type = account.debit_type -%]
    [%- END -%]
    [%- PROCESS account_status_description account=account -%]
[%- END -%]

[%- BLOCK debit_type_description -%]
    [%- SWITCH debit_type.code -%]

    [%- CASE 'ACCOUNT' -%]
        <span>Frais d'abonnement</span>
    [%- CASE 'ACCOUNT_RENEW' -%]
        <span>Frais de renouvellement d'abonnement</span>
    [%- CASE 'ARTICLE_REQUEST' -%]
        <span>Frais de demande d'article</span>
    [%- CASE 'LOST' -%]
        <span>Document perdu</span>
    [%- CASE 'MANUAL' -%]
        <span>Frais manuel</span>
    [%- CASE 'NEW_CARD' -%]
        <span>Nouvelle carte</span>
    [%- CASE 'OVERDUE' -%]
        <span>Amende</span>
    [%- CASE 'PROCESSING' -%]
        <span>Frais de traitement pour exemplaire perdu</span>
    [%- CASE 'RENT' -%]
        <span>Frais de location</span>
    [%- CASE 'RENT_DAILY' -%]
        <span>Frais quotidien de location</span>
    [%- CASE 'RENT_RENEW' -%]
        <span>Renouvellement d'une location</span>
    [%- CASE 'RENT_DAILY_RENEW' -%]
        <span>Renouvellement d'une location quotidienne</span>
    [%- CASE 'RESERVE' -%]
        <span>Frais de réservation</span>
    [%- CASE 'RESERVE_EXPIRED' -%]
        <span>Réservation en attente depuis trop longtemps</span>
    [%- CASE 'PAYOUT' -%]
        <span>Paiement de la bibliothèque à l'utilisateur</span>
    [%- CASE 'VOID' -%]
        <span>Le crédit a été annulé</span>
    [%- CASE -%]
        <span>[% debit_type.description | html %]</span>
    [%- END -%]
[%- END -%]

[%- BLOCK credit_type_description -%]
    [%- SWITCH credit_type.code -%]

    [%- CASE 'CANCELLATION' -%]
        <span>Frais annulé</span>
    [%- CASE 'CREDIT' -%]
        <span>Crédit</span>
    [%- CASE 'DISCOUNT' -%]
        <span>Rabais</span>
    [%- CASE 'FORGIVEN' -%]
        <span>Amnistié</span>
    [%- CASE 'LOST_FOUND' -%]
        <span>Remboursement de frais d'exemplaire perdu</span>
    [%- CASE 'OVERPAYMENT' -%]
        <span>Remboursement pour paiement en trop</span>
    [%- CASE 'PAYMENT' -%]
        <span>Paiement</span>
    [%- CASE 'PROCESSING_FOUND' -%]
        <span>Remboursement de frais d'administration pour document perdu</span>
    [%- CASE 'PURCHASE' -%]
        <span>Achat</span>
    [%- CASE 'REFUND' -%]
        <span>Remboursement</span>
    [%- CASE 'WRITEOFF' -%]
        <span>Amnistie</span>
    [%- CASE -%]
        <span>[% credit_type.description | html %]</span>
    [%- END -%]
[%- END -%]

[%- BLOCK account_status_description -%]
    [%- SWITCH account.status -%]

    [%- CASE 'UNRETURNED' -%]
        <span> (En accumulation)</span>
    [%- CASE 'RETURNED' -%]
        <span> (Retourné)</span>
    [%- CASE 'REPLACED' -%]
        <span> (Remplacé)</span>
    [%- CASE 'REFUNDED' -%]
        <span> (Remboursé)</span>
    [%- CASE 'FORGIVEN' -%]
        <span> (Amnistié)</span>
    [%- CASE 'VOID' -%]
        <span> (Annulé)</span>
    [%- CASE 'LOST' -%]
        <span> (Perdu)</span>
    [%- CASE 'CANCELLED' -%]
        <span> (Annulé)</span>
    [%- CASE -%]

    [%- END -%]
[%- END -%]
