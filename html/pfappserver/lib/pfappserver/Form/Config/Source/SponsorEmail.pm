package pfappserver::Form::Config::Source::SponsorEmail;

=head1 NAME

pfappserver::Form::Config::Source::SponsorEmail - Web form for email-based self-registration by soonsor

=head1 DESCRIPTION

Form definition to create or update an guest-sponsored user source.

=cut

use HTML::FormHandler::Moose;
extends 'pfappserver::Form::Config::Source';
with 'pfappserver::Base::Form::Role::Help';
with 'pfappserver::Base::Form::Role::SourceLocalAccount';

use pfappserver::Form::Field::Duration;
use pf::Authentication::Source::SponsorEmailSource;

# Form fields
has_field 'allow_localdomain' =>
  (
   type => 'Toggle',
   checkbox_value => 'yes',
   unchecked_value => 'no',
   label => 'Allow Local Domain',
   default => pf::Authentication::Source::SponsorEmailSource->meta->get_attribute('allow_localdomain')->default,
   tags => { after_element => \&help,
             help => 'Accept self-registration with email address from the local domain' },
  );

has_field 'email_activation_timeout' =>
  (
   type => 'Duration',
   label => 'Email Activation Timeout',
   required => 1,
   default => pfappserver::Form::Field::Duration->duration_inflate(pf::Authentication::Source::SponsorEmailSource->meta->get_attribute('email_activation_timeout')->default),
   tags => { after_element => \&help,
             help => 'Delay given to a sponsor to click the activation link.' },
  );

has_field 'activation_domain' =>
  (
   type => 'Text',
   label => 'Host in activation link',
   required => 0,
    tags => {
        after_element => \&help,
        help => 'Set this value if you want to change the hostname in the validation link. Changing this requires to restart haproxy to be fully effective.',
    },
  );

has_field 'sponsorship_bcc' => (
    type        => 'Text',
    label       => 'Sponsorship BCC',
    required    => 0,
    tags        => {
        after_element   => \&help,
        help            => "Sponsors requesting access and access confirmation emails are BCC'ed to this address. Multiple destinations can be comma separated.",
    },
);

=head1 COPYRIGHT

Copyright (C) 2005-2018 Inverse inc.

=head1 LICENSE

This program is free software; you can redistribute it and/or
modify it under the terms of the GNU General Public License
as published by the Free Software Foundation; either version 2
of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program; if not, write to the Free Software
Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301,
USA.

=cut

__PACKAGE__->meta->make_immutable unless $ENV{"PF_SKIP_MAKE_IMMUTABLE"};

1;
