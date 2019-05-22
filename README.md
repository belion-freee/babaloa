# Babaloa

This is a gem that will convert to CSV if you pass an array. In addition to conversion, sorting, column specification, and translation can be optionally specified.
You can also register default settings in initializers.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'babaloa'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install babaloa

## Usage
It is very easy to use. Pass an array as an argument. CSV file is generated.

```ruby
arr = [["col1", "col2", "col3"],["row1-1", "row1-2", "row1-3"],["row2-1", "row2-2", "row2-3"]]
Babaloa.to_csv(arr) # => "col1,col2,col3\nrow1-1,row1-2,row1-3\nrow2-1,row2-2,row2-3\n"
```

You can also use Hash for the contents of the array. Like this.

```ruby
arr = [{"col1" => "row1-1", "col2" => "row1-2", "col3" => "row1-3"},{ "col1" => "row2-1", "col2" => "row2-2", "col3" => "row2-3"}]
Babaloa.to_csv(arr) # => "col1,col2,col3\nrow1-1,row1-2,row1-3\nrow2-1,row2-2,row2-3\n"
```

## Options
Introduces the available options.

### Sort options
You can sort content for using sort options.
**Be sure to use the same hash key type as the header name** to be specified. It does not move if the type is different. In addition, in case of comparing with `2, 3, 100` note that the order will be `100, 2, 3` when comparing by character string.

```ruby
arr = [{ "col1" => "row2-1", "col2" => "row2-2", "col3" => "row2-3"},{"col1" => "row1-1", "col2" => "row1-2", "col3" => "row1-3"}]
Babaloa.to_csv(arr, sort: "col1") # => "col1,col2,col3\nrow1-1,row1-2,row1-3\nrow2-1,row2-2,row2-3\n"
```

### Only/Except options
You can sort content for using sort options if you use Hash for the contents of the array.


## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `./qs spec` to run the tests. You can also run `./qs run app bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `./qs rake install`. To release a new version, update the version number in `version.rb`, and then run `./qs rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/belion-freee/babaloa.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
