package Syntactic::Practice::Types;

use Syntactic::Practice::Util;

use Moose;
use Moose::Util::TypeConstraints;
use namespace::autoclean;

my $ns = 'Syntactic::Practice';

my $schema = "${ns}::Util"->get_schema();

subtype 'True', as 'Bool', where { $_ },
  message { "The value you provided, $_, was not true" };
subtype 'False', as 'Bool', where { !$_ },
  message { "The value you provided, $_, was not false" };

Log::Log4perl->get_logger()->debug( "False type has been defined" );

my %type_class = ( Tree         => 'Tree',
                   AbstractTree => 'Tree::Abstract',
                   Category     => 'Grammar::Category',
                   Grammar      => 'Grammar',
                   Category     => 'Grammar::Category',
                   Rule         => 'Grammar::Rule',
                   Term         => 'Grammar::Term',
                   Factor       => 'Grammar::Factor',
                   Tree         => 'Tree',
                   AbstractTree => 'Tree::Abstract',
                   Lexicon      => 'Lexicon',
                   Homograph    => 'Lexicon::Homograph',
                   Lexeme       => 'Lexicon::Lexeme',
                   Analysis     => 'Lexer::Analysis',
                   Lexer        => 'Lexer',
                   Token        => 'Grammar::Token',
                   TokenSet     => 'Grammar::TokenSet',
                   Parser       => 'Parser', );
my %type_role = ( CategoryRole => 'Roles::Category' );

while ( my ( $type, $class ) = each %type_class ) {
  class_type $type => { class => "${ns}::$class" };
}

while ( my ( $type, $role ) = each %type_role ) {
  role_type $type => { role => "${ns}::$role" };
}

subtype 'Undefined', as 'Undef', where { !defined $_ },
  message { "The value you provided, $_, was not undefined" };

maybe_type 'Tree';
maybe_type 'Token';
maybe_type 'NonTerminalAbstractTree';

my %categoryLabel = ( Start       => [ "${ns}::Util"->get_start_labels ],
                      Lexical     => [ "${ns}::Util"->get_lexical_labels ],
                      Phrasal     => [ "${ns}::Util"->get_phrasal_labels ],
                      Terminal    => [ "${ns}::Util"->get_terminal_labels ],
                      NonTerminal => [ "${ns}::Util"->get_nonterminal_labels ],
                      Syntactic   => [ "${ns}::Util"->get_syntactic_labels ], );

my %typeMap = (
                Syntactic => { base  => 'SyntacticCategoryLabel',
                               super => 'Str',
                               key   => 'Syntactic'
                },
                NonTerminal => { base  => 'NonTerminalCategoryLabel',
                                 super => 'SyntacticCategoryLabel',
                                 key   => 'NonTerminal'
                },
                Terminal => { base  => 'TerminalCategoryLabel',
                              super => 'SyntacticCategoryLabel',
                              key   => 'Terminal'
                },
                Lexical => { base  => 'LexicalCategoryLabel',
                             super => 'TerminalCategoryLabel',
                             key   => 'Terminal'
                },
                Phrasal => { base  => 'PhrasalCategoryLabel',
                             super => 'NonTerminalCategoryLabel',
                             key   => 'NonTerminal'
                },
                Start => { base  => 'StartCategoryLabel',
                           super => 'NonTerminalCategoryLabel',
                           key   => 'Start'
                } );

my $msg_format = 'The label you provided, %s, is not a %s';
foreach
  my $cat_type ( qw( Syntactic NonTerminal Terminal Phrasal Lexical Start ) )
{
  my ( $base, $super, $key ) = @{ $typeMap{$cat_type} }{qw( base super key )};

  subtype $base => as $super => where {
    my $input = $_;
    grep { $_ eq $input } @{ $categoryLabel{$key} };
  },
    message {
    sprintf( $msg_format, $_, $base );
    };

  Log::Log4perl->get_logger()->debug( "$base => $super" );
}

Log::Log4perl->get_logger()->debug( "Label types have been defined" );

subtype 'PositiveInt', as 'Int',
  where { $_ >= 0 },
  message { "The number you provided, $_, was not a positive number" };

my $lexeme_rs = $schema->resultset( 'Lexeme' )->search();

subtype 'Word', as 'Str', where {
  scalar $lexeme_rs->search( { 'LOWER(me.word)' => { 'LIKE' => lc( $_ ) } } )
    ->all();
}, message {
  "The word you provided, $_, is not in the lexicon";
};

Log::Log4perl->get_logger()->debug( "Word type has been defined" );

Log::Log4perl->get_logger()->debug( "PositiveInt type has been defined" );

foreach my $s_type ( "${ns}::Util"->get_syntactic_types ) {
  class_type "${s_type}Tree" => { class => "${ns}::Tree::${s_type}" };

#  class_type "${s_type}AbstractTree" => { class => "${ns}::Tree::${s_type} | ${ns}::Tree::Abstract::${s_type}" };
  class_type "${s_type}AbstractTree" =>
    { class => "${ns}::Tree::Abstract::${s_type}" };

#  Log::Log4perl->get_logger()
#      ->debug( "Abstract Tree: ${s_type}AbstractTree  => [${s_type}Tree | ${ns}::Tree::Abstract::${s_type}" );
#  subtype "${s_type}AbstractTree" => as "${ns}::Tree::${s_type} | ${ns}::Tree::Abstract::${s_type}";
  role_type "${s_type}CategoryRole" =>
    { role => "${ns}::Roles::Category::${s_type}" };
  class_type "${s_type}Category" =>
    { class => "${ns}::Grammar::Category::${s_type}" };
  class_type "${s_type}Factor" =>
    { class => "${ns}::Grammar::Factor::${s_type}" };
  class_type "${s_type}Term" => { class => "${ns}::Grammar::Term::${s_type}" };
  class_type "${s_type}Rule" => { class => "${ns}::Grammar::Rule::${s_type}" };
}

Log::Log4perl->get_logger()
  ->debug( "TerminalAbstractTree type has been defined" );

subtype 'SynCatLabelList', as 'ArrayRef[SyntacticCategoryLabel]';
coerce 'SynCatLabelList', from 'SyntacticCategoryLabel', via { [$_] };

subtype 'LexCatLabelList', as 'ArrayRef[LexicalCategoryLabel]';
coerce 'LexCatLabelList', from 'LexicalCategoryLabel', via { [$_] };

subtype 'PhrCatLabelList', as 'ArrayRef[PhrasalCategoryLabel]';
coerce 'PhrCatLabelList', from 'PhrasalCategoryLabel', via { [$_] };

subtype 'WordList', as 'ArrayRef[Word]';
coerce 'WordList', from 'Word', via { [$_] };

subtype 'FactorList', as 'ArrayRef[Factor]',
  where { scalar @$_ > 0 },
  message { "The Factor list you provided, [@$_], was empty" };

__PACKAGE__->meta->make_immutable;
