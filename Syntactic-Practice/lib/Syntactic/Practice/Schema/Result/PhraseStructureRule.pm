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

=head2 symb_count

  data_type: 'integer'
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "target_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "symb_count",
  { data_type => "integer", is_nullable => 0 },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");

=head1 RELATIONS

=head2 symbols

Type: has_many

Related object: L<Syntactic::Practice::Schema::Result::Symbol>

=cut

__PACKAGE__->has_many(
  "symbols",
  "Syntactic::Practice::Schema::Result::Symbol",
  { "foreign.rule_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);


# Created by DBIx::Class::Schema::Loader v0.07042 @ 2016-01-28 19:15:29
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:XRNJMwBJMpjAHHVOFx7Cqg


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
