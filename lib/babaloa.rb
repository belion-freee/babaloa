require "babaloa/version"
require "babaloa/config"
require "csv"

module Babaloa
  class BabaloaError < StandardError; end

  class << self
    def to_csv(data, h = true, **options)
      raise BabaloaError, "data must be Array" unless data.is_a?(Array)
      raise BabaloaError, "content must be Array or Hash" unless data.empty? || data.first.is_a?(Array) || data.first.is_a?(Hash)

      if h && !data.empty?
        if data.first.is_a?(Hash)
          header = data.first.keys.map(&:to_sym)
          header = only_by(header, **options)
          header = except_by(header, **options)
        else
          header = data.first.map(&:to_sym)
          data = data.drop(1)
        end

        data = order_by(data, header, **options)
      end

      CSV.generate do |csv|
        csv << transrate_by(header.dup, **options) if h && header
        data.each{|res|
          if res.is_a?(Hash)
            raise BabaloaError, "Header required if content is Hash" unless h
            csv << header.map {|k| res[k] || res[k.to_s] }
          else
            csv << res
          end
        }
      end
    end

    def order_by(data, header, **options)
      sort = options[:sort] || configuration.define(options[:name], :sort) || configuration.default[:sort]
      return data unless sort

      conv = proc {|v| v.is_a?(String) && v =~ /^\d+$/ ? v.to_i : v }

      if sort.is_a?(Hash)
        k, v = sort.first
        k = header.index(k.to_sym) if data.first.is_a?(Array)
        data.sort_by! {|col| conv.(col[k]) }
        data.reverse! if v == :desc
      elsif sort.is_a?(Symbol) || sort.is_a?(String)
        sort = header.index(sort.to_sym) if data.first.is_a?(Array)
        data.sort_by! {|col| conv.(col[sort]) }
      else
        raise BabaloaError, "sort option must be Hash, Symbol, String."
      end

      data
    end

    def only_by(header, **options)
      only   = options[:only] || configuration.define(options[:name], :only) || configuration.default[:only]
      return header unless only

      if only.is_a?(Array)
        header.select! {|k| only.include?(k) }
      elsif only.is_a?(Symbol)
        header.select! {|k| only == k }
      else
        raise BabaloaError, "only option must be Array, Symbol"
      end

      header
    end

    def except_by(header, **options)
      except = options[:except] || configuration.define(options[:name], :except) || configuration.default[:except]
      return header unless except

      if except.is_a?(Array)
        header.reject! {|k| except.include?(k) }
      elsif except.is_a?(Symbol)
        header.reject! {|k| except == k }
      else
        raise BabaloaError, "except option must be Array, Symbol"
      end

      header
    end

    def transrate_by(header, **options)
      t = options[:t] || configuration.define(options[:name], :t) || configuration.default[:t]
      return header unless t

      if t.is_a?(Hash)
        header.map! {|k| t[k] || t[k.to_s] }.compact!
      else
        raise BabaloaError, "t option must be Hash"
      end

      header
    end
  end
end
