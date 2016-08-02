requires 'OpusVL::Website' => "0.08";
requires 'OpusVL::AppKitX::PasswordReset' => "0.03";
requires 'Code4Health::AppKitX::Users' => "0.04";
requires 'Code4Health::DB' => "0.07";
requires 'Code4Health::LDAP' => "0.05";
requires 'Email::MIME' => "1.929";
requires 'Email::Sender::Simple' => "1.300018";
requires 'Template::Plugin::JSON' => "0.06";
requires 'OpusVL::AppKitX::SysParams';

on 'test' => sub {
    requires 'OpusVL::AppKitX::PreferencesAdmin' => "0.02";
};
