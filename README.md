# libctags

This is a partial wrapper of [universal-ctags](https://docs.ctags.io/) code to 
*read* ctags files. It is not a complete wrapper, and it is not intended to be. 
It only covers the bits I want for my own projects, but if someone else uses it
it's easy to add the missing pieces.

It includes a very basic "readtags" program as an example of how to use it.


## Usage

1. Add the dependency to your `shard.yml`

```yaml
dependencies:
  cr-discount:
    github: ralsina/libctags.cr
```

2. Run `shards install`


## Contributing

1. Fork it (<https://github.com/ralsina/libctags/fork>)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## Contributors

- [Roberto Alsina](https://github.com/ralsina) - creator and maintainer
