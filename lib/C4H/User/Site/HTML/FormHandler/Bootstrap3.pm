package C4H::User::Site::HTML::FormHandler::Bootstrap3;

use Moose;
extends 'CatalystX::SimpleLogin::Form::Login';
with 'HTML::FormHandler::Widget::Wrapper::Bootstrap3';

has '+widget_wrapper' => (
    default => 'Bootstrap3'
);

1;
