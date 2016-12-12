
  function post(from, to, departure, arrival, train, route) {

    var form = document.createElement("form");
    form.setAttribute("method", "post");
    form.setAttribute("action", "/Map");

    var hiddenField1 = document.createElement("input");
    hiddenField1.setAttribute("type", "hidden");
    hiddenField1.setAttribute("name", "from");
    hiddenField1.setAttribute("value", from);
    form.appendChild(hiddenField1);

    var hiddenField2 = document.createElement("input");
    hiddenField2.setAttribute("type", "hidden");
    hiddenField2.setAttribute("name", "to");
    hiddenField2.setAttribute("value", to);
    form.appendChild(hiddenField2);

    var hiddenField3 = document.createElement("input");
    hiddenField3.setAttribute("type", "hidden");
    hiddenField3.setAttribute("name", "departure");
    hiddenField3.setAttribute("value", departure);
    form.appendChild(hiddenField3);

    var hiddenField4 = document.createElement("input");
    hiddenField4.setAttribute("type", "hidden");
    hiddenField4.setAttribute("name", "arrival");
    hiddenField4.setAttribute("value", arrival);
    form.appendChild(hiddenField4);

    var hiddenField5 = document.createElement("input");
    hiddenField5.setAttribute("type", "hidden");
    hiddenField5.setAttribute("name", "train");
    hiddenField5.setAttribute("value", train);
    form.appendChild(hiddenField5);

    var hiddenField6 = document.createElement("input");
    hiddenField6.setAttribute("type", "hidden");
    hiddenField6.setAttribute("name", "route");
    hiddenField6.setAttribute("value", route);
    form.appendChild(hiddenField6);

    document.body.appendChild(form);
    form.submit();
  }

  function buyTicket(from1, to1, from2, to2, departure1, arrival1, departure2, arrival2, train1ID, train2ID, price, km) {
    var form = document.createElement("form");
    form.setAttribute("method", "post");
    form.setAttribute("action", "/BuyTicket1");

    var hiddenField1 = document.createElement("input");
    hiddenField1.setAttribute("type", "hidden");
    hiddenField1.setAttribute("name", "from1");
    hiddenField1.setAttribute("value", from1);
    form.appendChild(hiddenField1);

    var hiddenField2 = document.createElement("input");
    hiddenField2.setAttribute("type", "hidden");
    hiddenField2.setAttribute("name", "to1");
    hiddenField2.setAttribute("value", to1);
    form.appendChild(hiddenField2);

    var hiddenField3 = document.createElement("input");
    hiddenField3.setAttribute("type", "hidden");
    hiddenField3.setAttribute("name", "from2");
    hiddenField3.setAttribute("value", from2);
    form.appendChild(hiddenField3);

    var hiddenField4 = document.createElement("input");
    hiddenField4.setAttribute("type", "hidden");
    hiddenField4.setAttribute("name", "to2");
    hiddenField4.setAttribute("value", to2);
    form.appendChild(hiddenField4);

    var hiddenField5 = document.createElement("input");
    hiddenField5.setAttribute("type", "hidden");
    hiddenField5.setAttribute("name", "departure1");
    hiddenField5.setAttribute("value", departure1);
    form.appendChild(hiddenField5);

    var hiddenField6 = document.createElement("input");
    hiddenField6.setAttribute("type", "hidden");
    hiddenField6.setAttribute("name", "arrival1");
    hiddenField6.setAttribute("value", arrival1);
    form.appendChild(hiddenField6);

    var hiddenField7 = document.createElement("input");
    hiddenField7.setAttribute("type", "hidden");
    hiddenField7.setAttribute("name", "departure2");
    hiddenField7.setAttribute("value", departure2);
    form.appendChild(hiddenField7);

    var hiddenField8 = document.createElement("input");
    hiddenField8.setAttribute("type", "hidden");
    hiddenField8.setAttribute("name", "arrival2");
    hiddenField8.setAttribute("value", arrival2);
    form.appendChild(hiddenField8);

    var hiddenField9 = document.createElement("input");
    hiddenField9.setAttribute("type", "hidden");
    hiddenField9.setAttribute("name", "train1ID");
    hiddenField9.setAttribute("value", train1ID);
    form.appendChild(hiddenField9);

    var hiddenField10 = document.createElement("input");
    hiddenField10.setAttribute("type", "hidden");
    hiddenField10.setAttribute("name", "train2ID");
    hiddenField10.setAttribute("value", train2ID);
    form.appendChild(hiddenField10);

    var hiddenField11 = document.createElement("input");
    hiddenField11.setAttribute("type", "hidden");
    hiddenField11.setAttribute("name", "price");
    hiddenField11.setAttribute("value", price);
    form.appendChild(hiddenField11);

    var hiddenField12 = document.createElement("input");
    hiddenField12.setAttribute("type", "hidden");
    hiddenField12.setAttribute("name", "km");
    hiddenField12.setAttribute("value", km);
    form.appendChild(hiddenField12);

    document.body.appendChild(form);
    form.submit();
  }

  function logout() {
    deleteCookie("validLogin");
    deleteCookie("username");
    deleteCookie("firstname");
    deleteCookie("lastname");
  }

  function writeLoginInformation(username, fname, lname) {
      document.cookie = "validLogin=true";
      document.cookie = "username=" + username;
      document.cookie = "firstname=" + fname;
      document.cookie = "lastname=" + lname;
  }

  function deleteCookie(cookieName) {
    document.cookie = cookieName + '=;expires=Thu, 01 Jan 1970 00:00:01 GMT;';
  }

  function getCookie(cookieName) {
    var cookie = document.cookie.split(';');
    for (var i = 0; i < cookie.length; i++) {
        if (cookie[i].includes(cookieName)) return cookie[i].substring(cookie[i].indexOf("=") + 1);
    }
  }

  function setActiveLink() {
    var url = document.URL;
    if (url.indexOf("TrainsAndTickets") != -1) {
      $("#2").addClass('active');
    } else if (url.indexOf("Login") != -1) {
      $("#3").addClass('active');
    } else if (url.indexOf("Register") != -1) {
      $("#4").addClass('active');
    } else if (url.indexOf("Registration") != -1) {
      return 0;
    } else if (url.indexOf("Authentificate") != -1) {
      return 0;
    } else if (url.indexOf("Search") != -1) {
      return 0;
    } else if (url.indexOf("Map") != -1) {
      return 0;
    } else if (url.indexOf("BuyTicket1") != -1) {
      return 0;
    } else {
      $("#1").addClass('active');
    }
  }

  function Slider() {
    jQuery(document).ready(function ($) {

        var jssor_1_SlideoTransitions = [
          [{b:-1,d:1,o:-1},{b:0,d:1000,o:1}],
          [{b:1900,d:2000,x:-379,e:{x:7}}],
          [{b:1900,d:2000,x:-379,e:{x:7}}],
          [{b:-1,d:1,o:-1,r:288,sX:9,sY:9},{b:1000,d:900,x:-1400,y:-660,o:1,r:-288,sX:-9,sY:-9,e:{r:6}},{b:1900,d:1600,x:-200,o:-1,e:{x:16}}]
        ];

        var jssor_1_options = {
          $AutoPlay: true,
          $SlideDuration: 3000,
          $Idle: 5000,
          $FillMode: 0,
          $PauseOnHover: 0,
          $SlideEasing: $Jease$.$OutQuint,
          $CaptionSliderOptions: {
            $Class: $JssorCaptionSlideo$,
            $Transitions: jssor_1_SlideoTransitions
          },
          $ArrowNavigatorOptions: {
            $Class: $JssorArrowNavigator$
          },
          $BulletNavigatorOptions: {
            $Class: $JssorBulletNavigator$
          }
        };

        var jssor_1_slider = new $JssorSlider$("jssor_1", jssor_1_options);

    });
  }
