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


# Created by DBIx::Class::Schema::Loader v0.07042 @ 2015-12-29 13:13:22
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:QGbzSFk2JnnKDPjJx5ujqw

__PACKAGE__->has_one(
  "cat",
  "Syntactic::Practice::Schema::Result::SyntacticCategory",
  { "foreign.id" => "self.cat_id"},
  { cascade_copy => 0, cascade_delete => 0 },
);


1;
