module Kernel

  # Yield self -or- return self.
  #
  #   "a".ergo.upcase #=> "A"
  #   nil.ergo.foobar #=> nil
  #
  #   "a".ergo{ |o| o.upcase } #=> "A"
  #   nil.ergo{ |o| o.foobar } #=> nil
  #
  # This is like #tap, but tap yields self -and- returns self.
  #
  # CREDIT: Daniel DeLorme

  def ergo &b
    if block_given?
      b.arity == 1 ? yield(self) : instance_eval(&b)
    else
      self
    end
  end

end

class NilClass

  # Compliments Kernel#ergo.
  #
  #   "a".ergo{ |o| o.upcase } #=> "A"
  #   nil.ergo{ |o| o.bar } #=> nil
  #
  # CREDIT: Daniel DeLorme

  def ergo
    @_ergo ||= Functor.new{ nil }
    @_ergo unless block_given?
  end

end

class Functor
  # Privatize all methods except vital methods and #binding.
  private(*instance_methods.select { |m| m !~ /(^__|^binding$)/ })

  def initialize(&function)
    @function = function
  end

  def to_proc
    @function
  end

  # Any action against the functor is processesd by the function.
  def method_missing(op, *args, &blk)
    @function.call(op, *args, &blk)
  end 
end
