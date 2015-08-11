bend
====

A wrapper around [battleschool] to enable sharing configuration setups between
computers and/or people.

I have more than one computer that I would like to set up using battleschool.
They need different configurations but I still want to keep the configuration
in a single place. Hence, this.

[battleschool]: https://github.com/spencergibb/battleschool


## Configuration

A normal `battleschool` configuration directory contains a file `config.yml`.
Bend will create this file for you by combining (in this order):

* `common.yml`
* `host/<host>.yml`
* `user/<user>.yml`

This allows you to specify the local playbooks, URLs and git repositories to
use on a global, per-host and per-user basis. Each file is optional (but at
least one must exist for this to make any sense).


## Why bend?

* it **bends** computers to your will?
* my laptop is called sinister, and I find it amusing to use the command
  `bend sinister` to set it up
