# XTP Email Responder

PoC of integrating XTP with Postfix

## Host Setup

In `/etc/postfix/master.cf`, under

```
smtp      inet  n       -       y       -       -       smtpd
```

Add

```
 -o content_filter=autoresponder:dummy
```

and at the bottom, add

```
autoresponder unix  -       n       n       -       -       pipe
 flags=Rq user=gavin argv=/home/gavin/dev/xtp-email-autoresponder/autoresponder.sh ${sender} ${recipient}
```

## Plugin setup

`schema.yaml` includes code sample for C++.

```
xtp plugin init --schema-file schema.yaml --name plugin --path plugin --feature stub-with-code-samples
```

Select C++.
