package pf::UnifiedApi::Controller::Crud;

=head1 NAME

pf::UnifiedApi::Controller::Crud -

=cut

=head1 DESCRIPTION

pf::UnifiedApi::Controller::Crud

=cut

use strict;
use warnings;
use Mojo::Base 'pf::UnifiedApi::Controller';
use pf::error qw(is_error);

has 'dal';
has 'id_key';
has 'resource_id' => 'id';

sub list {
    my ($self) = @_;
    my $number_of_results = $self->list_number_of_results;
    my $limit = $number_of_results + 1;
    my $cursor = $self->list_cursor();
    my ($status, $iter) = $self->dal->search(
        -limit => $limit,
        -offset => $cursor,
        -with_class => undef,
    );
    my $items = $iter->all;
    my $prevCursor = $cursor - $number_of_results;
    my %results = (
        items => $items,
    );
    if (@$items == $limit) {
        pop @$items;
        $results{nextCursor} = $cursor + $number_of_results
    }
    if ($prevCursor >= 0 ) {
        $results{prevCursor} = $prevCursor;
    }
    $self->render(json => \%results, status => $status);
}

sub list_cursor {
    my ($self) = @_;
    my $cursor = $self->req->param('cursor') // 0;
    $cursor += 0;
    if ($cursor < 0) {
        $cursor = 0;
    }
    return $cursor;
}

sub list_number_of_results {
    return 100;
}

sub get {
    my ($self) = @_;
    return $self->render_get(
        $self->do_get($self->get_lookup_info)
    );
}

sub get_lookup_info {
    my ($self) = @_;
    $self->build_item_lookup;
}

sub render_get {
    my ($self, $status, $item) = @_;
    if (is_error($status)) {
        return $self->render_error($status, "Unable to get resource");
    }
    return $self->render(json => { item => $item}, status => $status);
}

sub do_get {
    my ($self, $data) = @_;
    my ($status, $item) = $self->dal->find($data);
    return ($status, is_error($status) ? undef : $item->to_hash());
}

sub build_item_lookup {
    my ($self) = @_;
    return {
        $self->resource_id => $self->stash($self->id_key)
    };
}

sub create {
    my ($self) = @_;
    return $self->render_create(
        $self->do_create($self->make_create_data())
    );
}

sub render_create {
    my ($self, $status, $obj) = @_;
    if (is_error($status)) {
        return $self->render_error($status, "Unable to create resource");
    }
    $self->res->headers->location($self->make_location_url($obj));
    return $self->render(json => {}, status => $status);
}

sub make_location_url {
    my ($self, $obj) = @_;
    my $url = $self->url_for;
    my $id = $obj->{$self->resource_id};
    return "$url/$id";
}

sub make_create_data {
    my ($self) = @_;
    return $self->req->json;
}

sub do_create {
    my ($self, $data) = @_;
    my $obj = $self->dal->new($data);
    return ($obj->insert, $obj);
}

sub remove {
    my ($self) = @_;
    return $self->render_remove(
        $self->do_remove()
    );
}

sub render_remove {
    my ($self, $status) = @_;
    if (is_error($status)) {
        return $self->render_error($status, "Unable to remove resource");
    }
    return $self->render(json => {}, status => $status);
}

sub do_remove {
    my ($self) = @_;
    return $self->dal->remove_by_id($self->build_item_lookup);
}

=head2 update

update

=cut

sub update {
    my ($self) = @_;
    my $req = $self->req;
    my $res = $self->res;
    my $data = $self->update_data;
    my ($status, $count) = $self->dal->update_items(
        -where => $self->build_item_lookup,
        -set => {
            %$data,
        },
        -limit => 1,
    );
    if ($count == 0) {
        $status = 404;
    }
    $res->code($status);
    if ($res->is_error) {

    }
    return $self->render(json => {});
}

sub update_data {
    my ($self) = @_;
    return $self->req->json;
}

=head1 AUTHOR

Inverse inc. <info@inverse.ca>

=head1 COPYRIGHT

Copyright (C) 2005-2017 Inverse inc.

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

1;
