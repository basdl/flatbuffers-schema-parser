require 'parslet'
require 'pp'

class Mini < Parslet::Parser
    rule(:identifier) { match['a-zA-Z0-9"'].repeat(1) }
    rule(:space)      { match('\s').repeat(1) }
    rule(:space?)     { space.maybe }
    
    rule(:lparen)     { str('(') >> space? }
    rule(:rparen)     { str(')') >> space? }
    rule(:lbrace)     { str('{') >> space? }
    rule(:rbrace)     { str('}') >> space? }
    rule(:ledge)     { str('[') >> space? }
    rule(:redge)     { str(']') >> space? }
    rule(:comma)      { str(',') >> space? }
    rule(:semicolon)      { str(':') >> space? }
    rule(:spoint)      { str(';') >> space? }
    rule(:eql)      { str('=') >> space? }
    rule(:integer_constant) { match("-?[0-9]+").repeat(1) | str("true") | str("false") | identifier }
    rule(:float_constant) { match("-?[0-9]+.[0-9]+((e|E)(+|-)?[0-9]+)?") }
    rule(:scalar) { integer_constant | float_constant }
    rule(:single_value) { scalar | string_constant }
    rule(:string_constant) { str('"') >> match("[^\"]*") >> str('"') }
    
    rule(:ident) { identifier }
    rule(:type) { str("bool") | str("byte") | str("ubyte") | str("short") | str("ushort") | str("int") | str("uint") | str("float") | str("long") | str("ulong") | str("double") | str("string") | ledge >> identifier.as(:array) >> redge | identifier }

    rule(:inc) { str('include') >> space >> identifier >> space? >> spoint }

    rule(:field_decl) { identifier.as(:name) >> semicolon >> type.as(:type) >> space? >> ( eql >> space? >> scalar.as(:default) ).maybe >> space? >> metadata_commasep.as(:metadata) >> spoint }
    rule(:metadata_commasep) { ( lparen >> metadata >> (comma >> metadata).repeat >> rparen ).maybe }
    rule(:metadata) { identifier.as(:meta) >> space? >> (semicolon >> single_value.as(:value)).maybe >> space?  }

    rule(:attribute_decl) { str("attribute") >> space >> identifier.as(:name) >> spoint }
    rule(:enumval_decl) { identifier.as(:name) >> space? >> ( eql >> integer_constant.as(:value) ).maybe >> space? }
    rule(:enumval_decl_commasep) { enumval_decl >> (comma >> enumval_decl).repeat }
    rule(:enum_decl) { ( str("enum") | str("union") ).as(:type) >> space >> identifier.as(:name) >> space? >> ( semicolon >> type ).maybe >> metadata_commasep.as(:metadata) >> space? >> lbrace >> enumval_decl_commasep >> rbrace }
    rule(:namespace_decl) { str("namespace") >> space >> identifier.as(:name) >> spoint }
    rule(:type_decl) { ( str("table") | str("struct") ).as(:type) >> space >> identifier.as(:name) >> space >> metadata_commasep.as(:metadata) >> lbrace >> field_decl.repeat(1).as(:fields) >> rbrace }
    rule(:root_decl) { str("root_type") >> space >> identifier.as(:type) >> spoint } 
    rule(:schema) { inc.maybe.as(:includes) >> space? >> (namespace_decl.as(:namespace) | type_decl.as(:type) | enum_decl.as(:enum) | attribute_decl.as(:attribute) | root_decl.as(:roottype) ).repeat(1) }
    
    root(:schema)
end
