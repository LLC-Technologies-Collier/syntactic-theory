package Syntactic::Practice::Types;

use Syntactic::Practice::Util;

use Moose;
use Moose::Util::TypeConstraints;

my $schema             = Syntactic::Practice::Util->get_schema();
my @startCategoryLabel = Syntactic::Practice::Util->get_start_category_labels();

my @args = ( {}, { distinct => 1 } );
my @SynCatType = qw(Phrasal Lexical);

enum 'SynCatType', [ map { lc $_ } @SynCatType ];

my %categoryLabel = ( Start => \@startCategoryLabel );

my $msg_format = 'The %s category label you provided, %s, is not recognized';
foreach my $cat_type ( 'Syntactic', @SynCatType ) {
  my $rs_class  = $cat_type . 'Category';
  my $sub_type  = $rs_class . 'Label';
  my $base_type = ( $cat_type eq 'Syntactic' ? 'Str' : 'SyntacticCategoryLabel' );

  $categoryLabel{$cat_type} =
    [ map { $_->label }
      $schema->resultset( $rs_class )->search( @args )->all() ]
    unless exists $categoryLabel{$cat_type};

  subtype $sub_type, as $base_type, where {
    my $input = $_;
    grep { $_ eq $input } @{ $categoryLabel{$cat_type} };
  }, message {
    sprintf( $msg_format, $cat_type, $_ );
  };
}


subtype 'SynCatLabelList', as 'ArrayRef[SyntacticCategoryLabel]';
coerce 'SynCatLabelList', from 'SyntacticCategoryLabel', via { [$_] };

subtype 'LexCatLabelList', as 'ArrayRef[LexicalCategoryLabel]';
coerce 'LexCatLabelList', from 'LexicalCategoryLabel', via { [$_] };

subtype 'PhrCatLabelList', as 'ArrayRef[PhrasalCategoryLabel]';
coerce 'PhrCatLabelList', from 'PhrasalCategoryLabel', via { [$_] };

# TODO: change this when we have other types of terminal symbols
subtype 'TerminalCategoryLabel', as 'LexicalCategoryLabel';
subtype 'TerminalCatLabelList',  as 'LexCatLabelList';

# TODO: change this when we have other types of non-terminal symbols
subtype 'NonTerminalCategoryLabel', as 'PhrasalCategoryLabel';
subtype 'NonTerminalCatLabelList',  as 'PhrCatLabelList';

subtype 'StartCategoryLabel', as 'NonTerminalCategoryLabel', where {
  grep { $_ } @startCategoryLabel;
}, message {
  sprintf( $msg_format, 'Start', $_ );
};

my $lexeme_rs = $schema->resultset( 'Lexeme' )->search();

subtype 'Word', as 'Str',
  where { scalar $lexeme_rs->search( { word => $_ } )->all() },
  message { "The word you provided, $_, is not in the lexicon" };

subtype 'WordList', as 'ArrayRef[Word]';
coerce 'WordList', from 'Word', via { [$_] };

subtype 'SymbolList',
  as 'ArrayRef[Syntactic::Practice::Schema::Result::Symbol]',
  where { scalar @$_ > 0 },
  message { "The Symbol list you provided, [@$_], was empty" };

subtype 'PositiveInt', as 'Int',
  where { $_ >= 0 },
  message { "The number you provided, $_, was not a positive number" };

subtype 'True', as 'Bool', where { $_ },
  message { "The value you provided, $_, was not true" };
subtype 'False', as 'Bool', where { !$_ },
  message { "The value you provided, $_, was not false" };
subtype 'Undefined', as 'Undef', where { !defined $_ },
  message { "The value you provided, $_, was not undefined" };

no Moose;
__PACKAGE__->meta->make_immutable;
