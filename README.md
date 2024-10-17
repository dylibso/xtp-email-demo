# XTP Email Responder

PoC of integrating XTP with Postfix

## Plugin development

`make` builds `example-plugin` and a simulation consisting of a test and a mock host. After building all 3 plugins, the test is ran.

`make newplugin` creates a new plugin. Code samples are only stubbed for C++. See the `test` line in the `Makefile` for how you might test it.

## Host Setup (WIP)

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
