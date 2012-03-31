# encoding: utf-8

##
# Oedipus Sphinx 2 Search.
# Copyright © 2012 Chris Corbyn.
#
# See LICENSE file for details.
##

module Oedipus
  # Negation comparison of value.
  class Comparison::NotEqual < Comparison
    def to_s
      "!= #{Connection.quote(v)}"
    end

    def inverse
      Comparison::Equal.new(v)
    end
  end
end
