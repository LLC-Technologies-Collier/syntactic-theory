package Syntactic::Practice::Types;

use Moose;
use Moose::Util::TypeConstraints;

my $schema             = Syntactic::Practice::Util->get_schema();
my @startCategoryLabel = Syntactic::Practice::Util->get_start_category_labels();

my @SynCatType = Syntactic::Practice::Util->get_syntactic_category_types;

enum 'SynCatType', [ map { lc $_ } @SynCatType ];

my %categoryLabel = ( Start => \@startCategoryLabel );
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
  }

  my ( $base, $super, $key ) = @{ $typeMap{$cat_type} }{qw( base super key )};

  subtype $base, as $super, where {
    my $input = $_;
    grep { $_ eq $input } @{ $categoryLabel{$key} };
  }, message {
    sprintf( $msg_format, $_, $base );
  };
}

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

subtype 'FactorList', as 'ArrayRef[Syntactic::Practice::Grammar::Factor]',
  where { scalar @$_ > 0 },
  message { "The Factor list you provided, [@$_], was empty" };

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
