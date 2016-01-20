use utf8;
package Syntactic::Practice::Schema::Result::RuleNode;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Syntactic::Practice::Schema::Result::RuleNode

=head1 DESCRIPTION

Syntactic categories and sequence numbers which make up rules

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<rule_node>

=cut

__PACKAGE__->table("rule_node");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 rule_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 position

  data_type: 'integer'
  is_nullable: 0

=head2 cat_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 optional

  data_type: 'tinyint'
  default_value: 0
  is_nullable: 0

=head2 rpt

  data_type: 'tinyint'
  default_value: 0
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "rule_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "position",
  { data_type => "integer", is_nullable => 0 },
  "cat_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "optional",
  { data_type => "tinyint", default_value => 0, is_nullable => 0 },
  "rpt",
  { data_type => "tinyint", default_value => 0, is_nullable => 0 },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");

=head1 UNIQUE CONSTRAINTS

=head2 C<uniq_rule_position>

=over 4

=item * L</rule_id>

=item * L</position>

=back

=cut

__PACKAGE__->add_unique_constraint("uniq_rule_position", ["rule_id", "position"]);

=head1 RELATIONS

=head2 cat

Type: belongs_to

Related object: L<Syntactic::Practice::Schema::Result::SyntacticCategory>

=cut

__PACKAGE__->belongs_to(
  "cat",
  "Syntactic::Practice::Schema::Result::SyntacticCategory",
  { id => "cat_id" },
  { is_deferrable => 1, on_delete => "RESTRICT", on_update => "RESTRICT" },
);

=head2 rule

Type: belongs_to

Related object: L<Syntactic::Practice::Schema::Result::PhraseStructureRule>

=cut

__PACKAGE__->belongs_to(
  "rule",
  "Syntactic::Practice::Schema::Result::PhraseStructureRule",
  { id => "rule_id" },
  { is_deferrable => 1, on_delete => "RESTRICT", on_update => "RESTRICT" },
);


# Created by DBIx::Class::Schema::Loader v0.07042 @ 2016-01-14 17:17:49
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:H7dp47LC1AzaRHiSG9/faw


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
