
describe("login/registration modal behavior", function() {
  //responses for getThumbprint
  
  var responses = {
    success: {
      status: 200,
      response: "69:A1:56:73:A4:B2:78:42:56:69:A1:56:73:A4:B2:78:42:56:69:A1:56:73:A4:B2:78:42:56",
    },
    failure: {
      status: 500,
      response: "Invalid host",
    }
  };

  //vc credentials
  var credentials = {
    target: "1.2.3.4",
    user: "admin",
    password: "adminuser",
    thumbprint: "",
    appliancePassword: "12345"
  }

  var request;
  
  //defining fixtures path
    beforeAll(function(){
      var path = '';
      if (typeof window.__karma__ !== 'undefined') {
        path += 'base/'
      } 
      jasmine.getFixtures().fixturesPath = path + 'fixtures';
      preloadFixtures('index.html');
      
    });

    beforeEach(function() {
        loadFixtures( 'index.html');
        jasmine.Ajax.install();
    });
          
    afterEach(function() {
      jasmine.Ajax.uninstall();
    });

    it ("should be present only the registration modal with their elements", function() {      
      
      //Registration modal is still present
      expect($('#login-modal')).toBeVisible();
      
      //Registration form and their elements are present
      expect($('#login-form')).toBeVisible();
      expect($('#target')).toBeVisible();
      expect($('#user')).toBeVisible();
      expect($('input[name=password]')).toBeVisible();
      expect($('#login-submit')).toBeVisible();
    });    

    it ("Should has disabled the continue button when the fields were empty", function(){
      
      $('#target').val(credentials.target);
      checkRegistryForm();
      expect($('#login-submit').prop("disabled")).toBe(true);

      $('#user').val(credentials.user);
      checkRegistryForm();
      expect($('#login-submit').prop("disabled")).toBe(true);
      
      $('#password').val(credentials.password);
      checkRegistryForm();
      expect($('#login-submit').prop("disabled")).toBe(true);
      
      $('#appliancePwd').val(credentials.appliancePassword);
      checkRegistryForm();
      expect($('#login-submit').prop("disabled")).toBe(false);
    });

    it ("should has disabled the continue button when thumbprint input is empty", function(done) {
      
      $('#login-modal').css('display', 'none');
      $('#plugin-modal').css('display', '');
      
      $('#thumbprint-show').val("");
      checkThumbrintInput();
      expect($('#plugin-submit').prop("disabled")).toBe(true);

      $('#thumbprint-show').val(responses.success.response);
      checkThumbrintInput();
      expect($('#plugin-submit').prop("disabled")).toBe(false);
      done();
    });

    it ("should retrieve thumbprint when click submit button and hide registration modal", function(done) {
      var spyEvent = spyOnEvent('#login-submit', 'click');
      $('#target').val(credentials.target);
      $('#password').val(credentials.password);

      //Sending thumbprint request
      $('#login-submit').click(submitRegistration(event));
      $('#login-submit').click();
      request = jasmine.Ajax.requests.mostRecent();
      request.respondWith(responses.success);
      
      //The url of the request must have the target
      expect(request.url).toBe('/thumbprint?target='+credentials.target);
      //Thumbprint retrieve
      expect($('#thumbprint-show')).toHaveValue(responses.success.response);
      //Registration modal hide
      expect($('#login-modal')).toBeHidden();
      done();
    });

    it ("should remains registration modal when click submit button and thumbrint retrieval fails.", function(done) {
      var spyEvent = spyOnEvent('#login-submit', 'click');
      $('#login-submit').click(submitRegistration(event));
      $('#login-submit').click();

      request = jasmine.Ajax.requests.mostRecent();
      request.respondWith(responses.failure);  

      //Registration modal is still present
      expect($('#login-modal')).toBeVisible();
      //Plugin modal is still hidden
      expect($('#plugin-modal')).toBeHidden();
      //Show thumbprint retrieve failed
      expect($('#thumbprint-alert-div')).toBeVisible();
      done();
    });
  });
  