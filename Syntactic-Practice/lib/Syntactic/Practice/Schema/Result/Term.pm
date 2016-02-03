use utf8;
package Syntactic::Practice::Schema::Result::Term;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Syntactic::Practice::Schema::Result::Term - Terms representing different forms of rules

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<term>

=cut

__PACKAGE__->table("term");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 rule_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 fact_count

  data_type: 'integer'
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "rule_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "fact_count",
  { data_type => "integer", is_nullable => 0 },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");

=head1 RELATIONS

=head2 factors

Type: has_many

Related object: L<Syntactic::Practice::Schema::Result::Factor>

=cut

__PACKAGE__->has_many(
  "factors",
  "Syntactic::Practice::Schema::Result::Factor",
  { "foreign.term_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 rule

Type: belongs_to

Related object: L<Syntactic::Practice::Schema::Result::Rule>

=cut

__PACKAGE__->belongs_to(
  "rule",
  "Syntactic::Practice::Schema::Result::Rule",
  { id => "rule_id" },
  { is_deferrable => 1, on_delete => "RESTRICT", on_update => "RESTRICT" },
);


# Created by DBIx::Class::Schema::Loader v0.07042 @ 2016-02-03 13:09:02
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:96wIcFe8IIPchoCQyWtFqA


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
