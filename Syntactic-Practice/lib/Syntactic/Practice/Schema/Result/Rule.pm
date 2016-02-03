use utf8;
package Syntactic::Practice::Schema::Result::Rule;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Syntactic::Practice::Schema::Result::Rule - Rules indicating valid grammatical constructs

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<rule>

=cut

__PACKAGE__->table("rule");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 target_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "target_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");

=head1 RELATIONS

=head2 terms

Type: has_many

Related object: L<Syntactic::Practice::Schema::Result::Term>

=cut

__PACKAGE__->has_many(
  "terms",
  "Syntactic::Practice::Schema::Result::Term",
  { "foreign.rule_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);


# Created by DBIx::Class::Schema::Loader v0.07042 @ 2016-02-03 13:09:02
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:b3SgM6AfS1Al3mXlIzKS2Q


=head1 RELATIONS

=head2 target

Type: belongs_to

Related object: L<Syntactic::Practice::Schema::Result::PhrasalCategory>

=cut

__PACKAGE__->belongs_to(
  "target",
  "Syntactic::Practice::Schema::Result::PhrasalCategory",
  { id => "target_id" },
  { is_deferrable => 1, on_delete => "RESTRICT", on_update => "RESTRICT" },
);

1;
