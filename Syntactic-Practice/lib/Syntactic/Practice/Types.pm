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

Log::Log4perl->get_logger()
    ->debug( "False type has been defined" );


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
                   Token        => 'Lexer::Token',
                   Analysis     => 'Lexer::Analysis',
                   Lexer        => 'Lexer',
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

enum 'SynCatType',
  [ map { lc $_ } "${ns}::Util"->get_syntactic_category_types ];

my %categoryLabel = ( Start => [ "${ns}::Util"->get_start_category_labels ] );

my %typeMap = (
                Syntactic => { base  => 'SyntacticCategoryLabel',
                               super => 'Str',
                               rs    => 'SyntacticCategory',
                               key   => 'Syntactic'
                },
                NonTerminal => { base  => 'NonTerminalCategoryLabel',
                                 super => 'SyntacticCategoryLabel',
                                 rs    => 'PhrasalCategory',
                                 key   => 'NonTerminal'
                },
                Terminal => { base  => 'TerminalCategoryLabel',
                              super => 'SyntacticCategoryLabel',
                              rs    => 'LexicalCategory',
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
  my @valid_list;
  if ( exists $typeMap{$cat_type}->{rs} ) {
    $categoryLabel{$cat_type} =
      [ map { $_->label }
        $schema->resultset( $typeMap{$cat_type}->{rs} )
        ->search( {}, { distinct => 1 } )->all() ];
    Log::Log4perl->get_logger()
        ->debug( "$cat_type label list: " . Data::Printer::p( $categoryLabel{$cat_type} ) );

  }

  my ( $base, $super, $key ) = @{ $typeMap{$cat_type} }{qw( base super key )};

  subtype $base, as $super, where {
    my $input = $_;
    grep { $_ eq $input } @{ $categoryLabel{$key} };
  }, message {
    sprintf( $msg_format, $_, $base );
  };
}

Log::Log4perl->get_logger()
  ->debug( "Label types have been defined" );

foreach my $type ( "${ns}::Util"->get_tree_types ) {
  my ( $type, $class ) = ( "${type}Tree", "${ns}::Tree::${type}" );
  my $con_type = $type;
  class_type $type => { class => $class };
  $class =~ s/Tree/Tree::Abstract/;
  $type =~ s/Tree/AbstractTree/;
  Log::Log4perl->get_logger()
    ->debug( "Abstract Tree: $type  => [$con_type | $class]" );
  subtype $type => as "$con_type | $class";
  map { s/AbstractTree/CategoryRole/ }      ( $type );
  map { s/Tree::Abstract/Roles::Category/ } ( $class );
  role_type $type => { role => $class };
  map { s/Role// }         ( $type );
  map { s/Roles/Grammar/ } ( $class );
  class_type $type => { class => $class };
  map { s/Category/Factor/ } ( $type, $class );
  class_type $type => { class => $class };
  map { s/Factor/Term/ } ( $type, $class );
  class_type $type => { class => $class };
  map { s/Term/Rule/ } ( $type, $class );
  class_type $type => { class => $class };
}

Log::Log4perl->get_logger()
  ->debug( "Category, Role and Tree types have been defined" );


subtype 'SynCatLabelList', as 'ArrayRef[SyntacticCategoryLabel]';
coerce 'SynCatLabelList', from 'SyntacticCategoryLabel', via { [$_] };

subtype 'LexCatLabelList', as 'ArrayRef[LexicalCategoryLabel]';
coerce 'LexCatLabelList', from 'LexicalCategoryLabel', via { [$_] };

subtype 'PhrCatLabelList', as 'ArrayRef[PhrasalCategoryLabel]';
coerce 'PhrCatLabelList', from 'PhrasalCategoryLabel', via { [$_] };

my $lexeme_rs = $schema->resultset( 'Lexeme' )->search();

subtype 'Word', as 'Str', where {
  scalar $lexeme_rs->search( { 'LOWER(me.word)' => { 'LIKE' => lc( $_ ) } } )
    ->all();
}, message {
  "The word you provided, $_, is not in the lexicon";
};

subtype 'WordList', as 'ArrayRef[Word]';
coerce 'WordList', from 'Word', via { [$_] };

subtype 'FactorList', as 'ArrayRef[Factor]',
  where { scalar @$_ > 0 },
  message { "The Factor list you provided, [@$_], was empty" };

subtype 'PositiveInt', as 'Int',
  where { $_ >= 0 },
  message { "The number you provided, $_, was not a positive number" };

__PACKAGE__->meta->make_immutable;
