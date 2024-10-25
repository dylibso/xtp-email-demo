# XTP Email Responder

PoC of integrating XTP with Postfix

- [XTP Email Responder](#xtp-email-responder)
  - [Host Setup](#host-setup)
  - [Plugin development](#plugin-development)

## Host Setup

1. Get email with Postfix working. In order to use Thunderbird and probably some other mail clients, even for local email, you must setup a IMAP server such as `dovecot`.

2. Create the extension point. Go to https://xtp.dylibso.com, create an account if necessary, optionally create a team, and create an app and extension point, naming it `on email` and use the contents of `schema.yaml` as the schema. Note down your App ID.

3. Set XTP configuration: `cp .env.example .env`, fill in your App ID from the previous step and navigate to https://xtp.dylibso.com against, go to tokens, create a token an fill that in too. **IT IS CRUCIAL TO KEEP YOUR TOKEN SECRET.**

4. Set up the autoresponder. If Perl is installed with `cpanm`, you can install the XTP client library with `cpanm XTP`. Note, make sure you are installing in a way that Perl you are installing to will be accessible to the autoresponder running user. `cp autoresponder.sh.example autoresponder.sh` and modify as needed.

5. Configure postfix to use an autoresponder:

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
 flags=Rq user=USERNAME argv=/path/to/xtp-email-autoresponder/autoresponder.sh ${sender} ${recipient}
```

, filling in `USERNAME` with the user you want to run the autoresponder as and `path/to/xtp-email-autoresponder` with the path to `autoresponder.sh` .

Restart Postfix and try sending an email.

**HINT**: Configuring `/etc/aliases` can make testing easier.

## Plugin development

If the host is setup, you should be able to create a new plugin, build it, and push it with

```
xtp plugin init
xtp plugin build
xtp plugin push
```

(Selecting the `on email` extension point when doing `xtp plugin init`).

Otherwise locally, the `Makefile` provides some convenience commands:

`make` builds `example-plugin` and a simulation consisting of a test and a mock host. After building all 3 plugins, the test is ran.

`make newplugin` creates a new plugin. Code samples are only stubbed for C++. See the `test` line in the `Makefile` for how you might test it.
