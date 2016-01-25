package Syntactic::Practice::Types;

use Syntactic::Practice::Util;

use Moose;
use Moose::Util::TypeConstraints;

my $schema = Syntactic::Practice::Util->get_schema();

my @args = ( {}, { distinct => 1 } );

my @SynCatType = qw(Phrasal Lexical);

enum 'SynCatType', [map { lc $_ } @SynCatType];

my %categoryLabel;

foreach my $cat_type ( @SynCatType, 'Syntactic' ) {
  $categoryLabel{$cat_type} =
    [ map { $_->label }
      $schema->resultSet( "${cat_type}Category" )->search( @args )->all() ];
}

my $msg_format = 'The %s category label you provided, %s, is not recognized';

subtype 'SyntacticCategoryLabel', as 'Str',
  where { grep { $_ } @{ $categoryLabel{Syntactic} } },
  message { sprintf( $msg_format, 'Syntactic', $_ ) };

foreach my $cat_type ( @SynCatType ) {
  subtype '${cat_type}CategoryLabel', as 'SyntacticCategoryLabel',
    where { grep { $_ } @{ $categoryLabel{$cat_type} } },
    message { sprintf( $msg_format, $cat_type, $_ ) };
}

subtype 'SynCatLabelList', as 'ArrayRef[SyntacticCategoryLabel]';
coerce 'SynCatLabelList', from 'SyntacticCategoryLabel', via { [$_] };

subtype 'LexCatLabelList', as 'ArrayRef[LexicalCategoryLabel]';
coerce 'LexCatLabelList', from 'LexicalCategoryLabel', via { [$_] };

# TODO: change this when we have other types of terminal symbols
subtype 'TerminalCategoryLabel', as 'LexicalCategoryLabel';
subtype 'TerminalCatLabelList', as 'LexCatLabelList';

# TODO: change this when we have other types of non-terminal symbols
subtype 'NonTerminalCategoryLabel', as 'PhrasalCategoryLabel';
subtype 'NonTerminalCatLabelList', as 'PhrCatLabelList';


subtype 'PhrCatLabelList', as 'ArrayRef[PhrasalCategoryLabel]';
coerce 'PhrCatLabelList', from 'PhrasalCategoryLabel', via { [$_] };

my $lexeme_rs = $schema->resultSet( 'Lexeme' )->search();

subtype 'Word', as 'Str',
  where { scalar $lexeme_rs->search( { word => $_ } )->all() },
  message { "The word you provided, $_, is not in the lexicon" };

subtype 'WordList', as 'ArrayRef[Word]';
coerce 'WordList', from 'Word', via { [$_] };

subtype 'SymbolList', as 'ArrayRef[Syntactic::Practice::Grammar::Symbol]',
  where { scalar @$_ > 0 },
  message { "The Symbol list you provided, [@$_], was empty" };

subtype 'PositiveInt', as 'Int',
  where { $_ >= 0 },
  message { "The number you provided, $_, was not a positive number" };

no Moose;
__PACKAGE__->meta->make_immutable;
