# Application Policy CLI

The APCLI provides a dead simple way to generate an application policy.

## Application Policy Generation

CLI commands take the following format:
```
$ ruby create_policy.rb create <app-name> <secret1> <secret2> --<flag>
```

To generate a simple policy with three secrets:
```
$ ruby create_policy.rb create foo bar/baz3 baz/boom2 boom/foo1
```

To generate an application policy with a host factory:
```
$ ruby create_policy.rb create foo bar/baz3 baz/boom2 boom/foo1 --hostfactory
```

To generate an application policy with a host factory:
```
$ ruby create_policy.rb create foo bar/baz3 baz/boom2 boom/foo1,rotator:mysql,ttl:24h
```
