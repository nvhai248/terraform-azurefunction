class AzureConfig {
  // Azure Entra ID Configuration
  static const String clientId = String.fromEnvironment(
    'AZURE_CLIENT_ID',
    defaultValue: 'fe4c4971-249d-4fc8-bc38-2500ffa92816',
  );
  
  static const String tenantId = String.fromEnvironment(
    'AZURE_TENANT_ID', 
    defaultValue: '6670452e-996f-4fbc-9291-7847699c0c20',
  );
  
  static const String redirectUrl = String.fromEnvironment(
    'AZURE_REDIRECT_URL',
    defaultValue: 'msauth://com.microleap.mobile/Z%2BoSvUz5ycgTQ8P%2B31n%2FoMN%2FtGs%3D',
  );
  
  // Scopes for your custom API
  static const List<String> scopes = [
    'openid',
    'profile',
    'email',
    'offline_access',
    'https://graph.microsoft.com/.default',
  ];
  
  static const String authority = 'https://login.microsoftonline.com/$tenantId';
  static const String discoveryUrl = '$authority/v2.0/.well-known/openid_configuration';
}