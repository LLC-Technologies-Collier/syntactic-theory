use utf8;
package Syntactic::Practice::Schema::Result::SyntacticCategory;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Syntactic::Practice::Schema::Result::SyntacticCategory - A syntactic category of class lexical or phrasal

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<syntactic_category>

=cut

__PACKAGE__->table("syntactic_category");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 label

  data_type: 'varchar'
  is_nullable: 0
  size: 10

=head2 longname

  data_type: 'varchar'
  is_nullable: 0
  size: 64

=head2 ctype

  data_type: 'enum'
  extra: {list => ["lexical","phrasal"]}
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "label",
  { data_type => "varchar", is_nullable => 0, size => 10 },
  "longname",
  { data_type => "varchar", is_nullable => 0, size => 64 },
  "ctype",
  {
    data_type => "enum",
    extra => { list => ["lexical", "phrasal"] },
    is_nullable => 0,
  },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");

=head1 UNIQUE CONSTRAINTS

=head2 C<label>

=over 4

=item * L</label>

=back

=cut

__PACKAGE__->add_unique_constraint("label", ["label"]);

=head2 C<longname>

=over 4

=item * L</longname>

=back

=cut

__PACKAGE__->add_unique_constraint("longname", ["longname"]);

=head1 RELATIONS

=head2 factors

Type: has_many

Related object: L<Syntactic::Practice::Schema::Result::Factor>

=cut

__PACKAGE__->has_many(
  "factors",
  "Syntactic::Practice::Schema::Result::Factor",
  { "foreign.cat_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);


# Created by DBIx::Class::Schema::Loader v0.07042 @ 2016-02-03 13:22:41
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:HBhPiCyCdvvsun+Mna5RAw


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
