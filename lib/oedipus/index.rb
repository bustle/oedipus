# encoding: utf-8

##
# Oedipus Sphinx 2 Search.
# Copyright © 2012 Chris Corbyn.
#
# See LICENSE file for details.
##

module Oedipus
  # Representation of a search index for querying.
  class Index
    attr_reader :name
    attr_reader :attributes

    # Initialize the index named +name+ on the connection +conn+.
    #
    # @param [Symbol] name
    #   the name of an existing index in sphinx
    #
    # @param [Connection] conn
    #   an instance of Oedipus::Connection for querying
    def initialize(name, conn)
      @name       = name.to_sym
      @conn       = conn
      @attributes = reflect_attributes
    end

    # Insert the record with the ID +id+.
    #
    # @param [Integer] id
    #   the unique ID of the document in the index
    #
    # @param [Hash] hash
    #   a symbol-keyed hash of data to insert
    #
    # @return [Hash]
    #   a copy of the inserted record
    def insert(id, hash)
      data = Hash[
        [:id, *hash.keys.map(&:to_sym)].zip \
        [id,  *hash.values.map { |v| String === v ? @conn.quote(v) : v }]
      ]
      @conn.execute("INSERT INTO #{name} (#{data.keys.join(', ')}) VALUES (#{data.values.join(', ')})")
      attributes.merge(data.select { |k, _| attributes.key?(k) })
    end

    private

    def reflect_attributes
      rs = @conn.execute("DESC #{name}")
      {}.tap do |attrs|
        rs.each_hash do |row|
          case row['Type']
          when 'uint', 'integer' then attrs[row['Field'].to_sym] = 0
          when 'string'          then attrs[row['Field'].to_sym] = ""
          end
        end
      end
    end
  end
end
