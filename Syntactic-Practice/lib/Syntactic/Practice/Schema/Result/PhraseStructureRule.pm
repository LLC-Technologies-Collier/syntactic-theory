use utf8;
package Syntactic::Practice::Schema::Result::PhraseStructureRule;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Syntactic::Practice::Schema::Result::PhraseStructureRule - Rules indicating valid grammatical constructs

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<phrase_structure_rule>

=cut

__PACKAGE__->table("phrase_structure_rule");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 target_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 node_count

  data_type: 'integer'
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "target_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "node_count",
  { data_type => "integer", is_nullable => 0 },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");

=head1 RELATIONS

=head2 rule_nodes

Type: has_many

Related object: L<Syntactic::Practice::Schema::Result::RuleNode>

=cut

__PACKAGE__->has_many(
  "rule_nodes",
  "Syntactic::Practice::Schema::Result::RuleNode",
  { "foreign.rule_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);


# Created by DBIx::Class::Schema::Loader v0.07042 @ 2015-12-29 13:13:22
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:R2FsGjvlgqJ0c0S1D/1VCQ

__PACKAGE__->has_one(
  "target",
  "Syntactic::Practice::Schema::Result::PhrasalCategory",
  { "foreign.id" => "self.target_id"},
  { cascade_copy => 0, cascade_delete => 0 },
);

1;
