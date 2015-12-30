use utf8;
package Syntactic::Practice::Schema::Result::PhrasalCategory;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Syntactic::Practice::Schema::Result::PhrasalCategory - VIEW

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';
__PACKAGE__->table_class("DBIx::Class::ResultSource::View");

=head1 TABLE: C<phrasal_category>

=cut

__PACKAGE__->table("phrasal_category");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  default_value: 0
  is_nullable: 1

=head2 label

  data_type: 'varchar'
  is_nullable: 1
  size: 10

=head2 longname

  data_type: 'varchar'
  is_nullable: 1
  size: 64

=head2 head

  data_type: 'integer'
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", default_value => 0, is_nullable => 1 },
  "label",
  { data_type => "varchar", is_nullable => 1, size => 10 },
  "longname",
  { data_type => "varchar", is_nullable => 1, size => 64 },
  "head",
  { data_type => "integer", is_nullable => 0 },
);


# Created by DBIx::Class::Schema::Loader v0.07042 @ 2015-12-29 13:13:22
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:+FzH3Y7PU40W7Ddv4xC7lQ


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
