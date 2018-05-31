
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
    thumbprint: ""
  }

  var request;

    beforeAll(function(){
      var path = '';
      if (typeof window.__karma__ !== 'undefined') {
        path += 'base/'
      } 
      jasmine.getFixtures().fixturesPath = path + 'js/fixtures';
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
      expect(jQuery('#login-modal')).toBeVisible();
      
      //Registration form and their elements are present
      expect(jQuery('#login-form')).toBeVisible();
      expect(jQuery('#target')).toBeVisible();
      expect(jQuery('#user')).toBeVisible();
      expect(jQuery('input[name=password]')).toBeVisible();
      expect(jQuery('#login-submit')).toBeVisible();
    });    

    it ("should retrieve thumbprint when click submit button and hide registration modal", function(done) {
      var spyEvent = spyOnEvent('#login-submit', 'click');
      jQuery('#target').val(credentials.target);
      jQuery('input[name=password]').val(credentials.password);

      //Sending thumbprint request
      jQuery('#login-submit').click(submitRegistration());
      jQuery('#login-submit').click();
      request = jasmine.Ajax.requests.mostRecent();
      request.respondWith(responses.success);
      
      //The url of the request must have the target
      expect(request.url).toBe('/thumbprint?target='+credentials.target);
      //Thumbprint retrieve
      expect(jQuery('#thumbprint-show')).toHaveValue(responses.success.response);
      //Registration modal hide
      expect(jQuery('#login-modal')).toBeHidden();
      done();

    });

    it ("should remains registration modal when click submit button and thumbrint retrieval fails.", function(done) {
      var spyEvent = spyOnEvent('#login-submit', 'click');
      jQuery('#login-submit').click(submitRegistration());
      jQuery('#login-submit').click();

      request = jasmine.Ajax.requests.mostRecent();
      request.respondWith(responses.failure);

      //Registration modal is still present
      expect(jQuery('#login-modal')).toBeVisible();
      //Plugin modal is still hidden
      expect(jQuery('#plugin-modal')).toBeHidden();
      //Show thumbprint retrieve failed
      expect(jQuery('#thumbprint-alert-div')).toBeVisible();
      done();
    });
  });