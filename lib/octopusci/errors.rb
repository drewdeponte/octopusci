module Octopusci
  # Raised when a method that is meant to be pure virtual that is not overloaded is called
  class PureVirtualMethod < RuntimeError; end
end