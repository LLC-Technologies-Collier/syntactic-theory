use utf8;
package Syntactic::Practice::Schema::Result::Lexeme;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Syntactic::Practice::Schema::Result::Lexeme - Words available for use and their associated properties

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<lexeme>

=cut

__PACKAGE__->table("lexeme");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 word

  data_type: 'varchar'
  is_nullable: 1
  size: 64

=head2 cat_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "word",
  { data_type => "varchar", is_nullable => 1, size => 64 },
  "cat_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");


# Created by DBIx::Class::Schema::Loader v0.07042 @ 2016-01-28 19:15:29
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:BEg85lgFts9uEfsP7goKQA


=head1 RELATIONS

=head2 cat

Type: belongs_to

Related object: L<Syntactic::Practice::Schema::Result::LexicalCategory>

=cut

__PACKAGE__->belongs_to(
  "cat",
  "Syntactic::Practice::Schema::Result::LexicalCategory",
  { id => "cat_id" },
  { is_deferrable => 1, on_delete => "RESTRICT", on_update => "RESTRICT" },
);

1;
