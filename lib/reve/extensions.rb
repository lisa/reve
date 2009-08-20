require 'parsedate'

module Reve #:nodoc:
  # All of these are shamelessly nicked from Ruby on Rails. 
  # The String Extensions have a bit more fault tolerance.
  module Extensions

    module NilClass
      def to_date
        self
      end
      def to_time
        self
      end
    end
    
    module Hash
      def stringify_keys
        inject({}) do |h, (key,value)|
          h[key.to_s] = value
          h
        end
      end
      def stringify_keys!
        keys.each do |key|
          unless key.class.to_s == "String" # See ActiveSupport for why this is needed!
            self[key.to_s] = self[key]
            delete(key)
          end
        end
        self
      end
    end

    # Rails's cattr_ things. activesupport/lib/active_support/core_ext/class
    # Really quite handy.
    module Class #:nodoc:
      def cattr_reader(*syms) #:nodoc:
        syms.flatten.each do |sym|
          next if sym.is_a?(Hash)
          class_eval(<<-EOS, __FILE__, __LINE__)
            unless defined? @@#{sym}
              @@#{sym} = nil
            end

            def self.#{sym}
              @@#{sym}
            end

            def #{sym}
              @@#{sym}
            end
          EOS
        end
      end

      def cattr_writer(*syms) #:nodoc:
        options = syms.last.is_a?(Hash) ? syms.pop : {}
        syms.flatten.each do |sym|
          class_eval(<<-EOS, __FILE__, __LINE__)
            unless defined? @@#{sym}
              @@#{sym} = nil
            end

            def self.#{sym}=(obj)
              @@#{sym} = obj
            end
            #{"
            def #{sym}=(obj)
              @@#{sym} = obj
            end
            " unless options[:instance_writer] == false }
          EOS
        end
      end
      def cattr_accessor(*syms) #:nodoc:
        cattr_reader(*syms)
        cattr_writer(*syms)
      end
    end

    module String
      def to_time(form = :utc)
        begin
          ::Time.send(form, *ParseDate.parsedate(self))
        rescue Exception
          self
        end
      end
    end
  end
end

class String #:nodoc:
  include Reve::Extensions::String
end

class Class #:nodoc:
  include Reve::Extensions::Class
end

class Hash #:nodoc:
  include Reve::Extensions::Hash
end

class NilClass #:nodoc:
  include Reve::Extensions::NilClass
end

class Object
  def rsend(*args, &block)
    obj = self
    args.each do |a|
      b = (a.is_a?(Array) && a.last.is_a?(Proc) ? a.pop : block)
      obj = obj.__send__(*a, &b)
    end
    obj
  end
  alias_method :__rsend__, :rsend
end