[![CircleCI](https://circleci.com/gh/belion-freee/babaloa/tree/master.svg?style=svg&circle-token=b9268fffd3d7fe1e2d7639b718a4c307c761c607)](https://circleci.com/gh/belion-freee/babaloa/tree/master)

# Babaloa

This is a gem that will convert to CSV if you pass an array. In addition to conversion, sorting, column specification, and translation can be optionally specified.
You can also register default settings in initializers.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'babaloa'
```

And then execute:

    $ bundle install

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

### Ruby on Rails
If you use Ruby on Rails, you must to convert ActiveRecord object to Hash.
The easiest way is to add `map(&:attributes)` at the end of the search results.

```ruby
arr = SomeModel.all.map(&:attributes)
Babaloa.to_csv(arr)
```

## Options
Introduces the available options.

### Sort options
You can sort content for using sort options.
You can use option value with Hash(only use desc) or String, Symbol.

```ruby
arr = [{ "col1" => "row2-1", "col2" => "row2-2", "col3" => "row2-3"},{"col1" => "row1-1", "col2" => "row1-2", "col3" => "row1-3"}]
Babaloa.to_csv(arr, sort: "col1") # => "col1,col2,col3\nrow1-1,row1-2,row1-3\nrow2-1,row2-2,row2-3\n"
```

You can also use Hash for using desc. Like this.

```ruby
arr = [{ "col1" => "row2-1", "col2" => "row2-2", "col3" => "row2-3"},{"col1" => "row1-1", "col2" => "row1-2", "col3" => "row1-3"}]
Babaloa.to_csv(arr, sort: "col1") # => col1,col2,col3\nrow2-1,row2-2,row2-3\nrow1-1,row1-2,row1-3\n"
```

### Only/Except options
You can sort content for using sort options if you use Hash for the contents of the array.
You can use option value with Array or Symbol, String.

```ruby
arr = [{ "col1" => "row2-1", "col2" => "row2-2", "col3" => "row2-3"},{"col1" => "row1-1", "col2" => "row1-2", "col3" => "row1-3"}]
Babaloa.to_csv(arr, only: %i(col1, col2)) # => "col1,col2\nrow2-1,row2-2\nrow1-1,row1-2\n"
Babaloa.to_csv(arr, except: :col3) # => "col1,col2\nrow2-1,row2-2\nrow1-1,row1-2\n"
```

### Transrate options
You can transrate header for using t options.
You can only use option value with Hash.

```ruby
arr = [{ "col1" => "row2-1", "col2" => "row2-2", "col3" => "row2-3"},{"col1" => "row1-1", "col2" => "row1-2", "col3" => "row1-3"}]
Babaloa.to_csv(arr, t: {"col1" => "一番目", "col2" => "二番目", "col3" => "三番目"}) # => "一番目,二番目,三番目\nrow1-1,row1-2,row1-3\nrow2-1,row2-2,row2-3\n"
```

## Initializer
You can set options by default in initializers.

### default
Describes the settings applied to all csv output. The usage of the options is the same.

```ruby
Babaloa.configure {|config|
    config.default = {
      except: %i(updated_at created_at),
      sort: { id: :desc },
      t: { id: "ID", name: "NAME", age: "AGE" }
    }
}
```

### definition
Describe the settings that apply separately. The usage of the options is the same.

```ruby
Babaloa.configure {|config|
    config.definition = {
      test: {
        except: %i(updated_at created_at),
        sort: { id: :desc },
        t: { id: "ID", name: "NAME", age: "AGE" }
      }
    }
}
```

And use it like this.

```ruby
Babaloa.to_csv(arr, name: :test)
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `./qs spec` to run the tests. You can also run `./qs run app bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `./qs rake install`. To release a new version, update the version number in `version.rb`, and then run `./qs rake build` and `./qs run gem push pkg/babaloa-x.x.x.gem`, which will push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/belion-freee/babaloa.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
