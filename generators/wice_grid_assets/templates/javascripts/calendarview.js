//
// CalendarView (for Prototype)
// calendarview.org
//
// Maintained by Justin Mecham <justin@aspect.net>
//
// Portions Copyright 2002-2005 Mihai Bazon
//
// This calendar is based very loosely on the Dynarch Calendar in that it was
// used as a base, but completely gutted and more or less rewritten in place
// to use the Prototype JavaScript library.
//
// As such, CalendarView is licensed under the terms of the GNU Lesser General
// Public License (LGPL). More information on the Dynarch Calendar can be
// found at:
//
//   www.dynarch.com/projects/calendar
//


/* This fork by Yuri Leikind ( git://github.com/leikind/calendarview.git ) adds a number of features.

The differences from the original are

* Support for time in the form of two dropdowns for hours and minutes. Can be turned off/on.
* Draggable popup calendars (which introduces new dependancies: script.aculo.us effects.js and dragdrop.js)
* Close button
* Ability to unset the date by clicking on the active date
* Simple I18n support
* Removed all ambiguity in the API
* Two strategies in positioning of popup calendars: relative to the popup trigger element (original behavior),
  and is relative to the mouse pointer (can be configured)
* Popup calendars  are not created every time they pop up, on the contrary, they are created once just like
  embedded calendars, and then shown or hidden.
* Possible to have many popup calendars on page. The behavior of the original calendarview when a popup
  calendar is hidden when the user clicks elsewhere on the page is an option now.
* Refactoring and changes to the OO design like getting rid of Calendar.prototype in favor of class based
  OO provided by OO, and getting rid of Calendar.setup({}) in favor of a simple object constructor new Calendar({}).

*/

var Calendar = Class.create({

  container: null,

  minYear: 1900,
  maxYear: 2100,

  date: new Date(),
  currentDateElement: null,

  shouldClose: false,
  isPopup: true,

  initialize: function(params){

    if (! Calendar.init_done){
      Calendar.init();
    }

    embedAt                   = params.embedAt              || null;
    withTime                  = params.withTime             || null;
    dateFormat                = params.dateFormat           || null;
    initialDate               = params.initialDate          || null;
    popupTriggerElement       = params.popupTriggerElement        || null;
    this.onHideCallback       = params.onHideCallback             || function(date, calendar){};
    this.onDateChangedCallback     = params.onDateChangedCallback || function(date, calendar){};
    this.minuteStep                = params.minuteStep            || 5;
    this.hideOnClickOnDay          = params.hideOnClickOnDay      || false;
    this.hideOnClickElsewhere      = params.hideOnClickElsewhere  || false;
    this.outputFields              = params.outputFields          || $A();
    this.popupPositioningStrategy  = params.popupPositioningStrategy || 'trigger'; // or 'pointer'
    this.x = params.x || 0;
    this.y = params.y || 0.6;

    this.outputFields = $A(this.outputFields).collect(function(f){
      return $(f);
    });

    if (embedAt){
      this.embedAt = $(embedAt);
      this.embedAt._calendar = this;
    }else{
      this.embedAt = null;
    }

    this.withTime      = withTime;

    if (dateFormat){
      this.dateFormat = dateFormat;
    }else{
      if(this.withTime){
        this.dateFormat = Calendar.defaultDateTimeFormat;
      }else{
        this.dateFormat = Calendar.defaultDateFormat;
      }
    }

    this.dateFormatForHiddenField = params.dateFormatForHiddenField || this.dateFormat;


    if (initialDate) {
      this.date = this.parseDate(initialDate);
    }

    this.build();

    if (this.isPopup) { //Popup Calendars
      var popupTriggerElement = $(popupTriggerElement);
      popupTriggerElement._calendar = this;

      popupTriggerElement.observe('click', function(event){
        this.showAtElement(event, popupTriggerElement);
      }.bind(this) );

    } else{ // In-Page Calendar
      this.show();
    }

    if (params.updateOuterFieldsOnInit){
      this.updateOuterFieldWithoutCallback(); // Just for the sake of localization and DatePicker
    }
  },

  build: function(){
    if (this.embedAt) {
      var parentForCalendarTable = this.embedAt;
      this.isPopup = false;
    } else {
      var parentForCalendarTable = document.getElementsByTagName('body')[0];
      this.isPopup = true;
    }


    var table = new Element('table');

    var thead = new Element('thead');
    table.appendChild(thead);

    var firstRow  = new Element('tr');

    if (this.isPopup){
      var cell = new Element('td');
      cell.addClassName('draggableHandler');
      firstRow.appendChild(cell);

      cell = new Element('td', { colSpan: 5 });
      cell.addClassName('title' );
      cell.addClassName('draggableHandler');
      firstRow.appendChild(cell);

      cell = new Element('td');
      cell.addClassName('closeButton');
      firstRow.appendChild(cell);
      cell.update('x');

      cell.observe('mousedown', function(){
        this.hide();
      }.bind(this));


    }else{
      var cell = new Element('td', { colSpan: 7 } );
      firstRow.appendChild(cell);
    }

    cell.addClassName('title');

    thead.appendChild(firstRow);

    var row = new Element('tr')
    this._drawButtonCell(row, '&#x00ab;', 1, Calendar.NAV_PREVIOUS_YEAR);
    this._drawButtonCell(row, '&#x2039;', 1, Calendar.NAV_PREVIOUS_MONTH);
    this._drawButtonCell(row,   Calendar.getMessageFor('today'),    3, Calendar.NAV_TODAY);
    this._drawButtonCell(row, '&#x203a;', 1, Calendar.NAV_NEXT_MONTH);
    this._drawButtonCell(row, '&#x00bb;', 1, Calendar.NAV_NEXT_YEAR);
    thead.appendChild(row)

    // Day Names
    row = new Element('tr');
    for (var i = 0; i < 7; ++i) {
      cell = new Element('th').update(Calendar.SHORT_DAY_NAMES[i]);
      if (i == 0 || i == 6){
        cell.addClassName('weekend');
      }
      row.appendChild(cell);
    }
    thead.appendChild(row);

    // Calendar Days
    var tbody = table.appendChild(new Element('tbody'));
    for (i = 6; i > 0; --i) {
      row = tbody.appendChild(new Element('tr'));
      row.addClassName('days');
      for (var j = 7; j > 0; --j) {
        cell = row.appendChild(new Element('td'));
        cell.calendar = this;
      }
    }

    // Time Placeholder
    if (this.withTime){
      var tfoot = table.appendChild(new Element('tfoot'));
      row = tfoot.appendChild(new Element('tr'));
      cell = row.appendChild(new Element('td', { colSpan: 7 }));
      cell.addClassName('time');
      var hourSelect = cell.appendChild(new Element('select', { name : 'hourSelect'}));
      for (var i = 0; i < 24; i++) {
        hourSelect.appendChild(new Element('option', {value : i}).update(i));
      }
      this.hourSelect = hourSelect;

      cell.appendChild(new Element('span')).update(' : ');

      var minuteSelect = cell.appendChild(new Element('select', { name : 'minuteSelect'}));
      for (var i = 0; i < 60; i += this.minuteStep) {
        minuteSelect.appendChild(new Element('option', {value : i}).update(i));
      }
      this.minuteSelect = minuteSelect;

      hourSelect.observe('change', function(event){
        if (! this.date) return;
        var elem = event.element();
        var selectedIndex = elem.selectedIndex;
        if ((typeof selectedIndex != 'undefined') && selectedIndex != null){
          this.date.setHours(elem.options[selectedIndex].value);
          this.updateOuterField();
        }
      }.bind(this));

      minuteSelect.observe('change', function(event){
        if (! this.date) return;
        var elem = event.element();
        var selectedIndex = elem.selectedIndex;
        if ((typeof selectedIndex != 'undefined') && selectedIndex != null){
          this.date.setMinutes(elem.options[selectedIndex].value);
          this.updateOuterField();
        }
      }.bind(this))
    }

    // Calendar Container (div)
    this.container = new Element('div');
    this.container.addClassName('calendar');
    if (this.isPopup) {
      this.container.setStyle({ position: 'absolute', display: 'none' });
      this.container.addClassName('popup');
    }
    this.container.appendChild(table);

    this.update(this.date);

    Event.observe(this.container, 'mousedown', Calendar.handleMouseDownEvent);

    parentForCalendarTable.appendChild(this.container);

    if (this.isPopup){
      new Draggable(table, {handle : firstRow });
    }
  },

  updateOuterFieldReal: function(element){
    if (element.tagName == 'DIV' || element.tagName == 'SPAN') {
      formatted = this.date ? this.date.print(this.dateFormat) : '';
      element.update(formatted);
    } else if (element.tagName == 'INPUT') {
      formatted = this.date ? this.date.print(this.dateFormatForHiddenField) : '';
      element.value = formatted;
    }
  },

  updateOuterFieldWithoutCallback: function(){
    this.outputFields.each(function(field){
      this.updateOuterFieldReal(field);
    }.bind(this));
  },

  updateOuterField: function(){
    this.updateOuterFieldWithoutCallback();
    this.onDateChangedCallback(this.date, this);
  },

  viewOutputFields: function(){
    return this.outputFields.findAll(function(element){
      if (element.tagName == 'DIV' || element.tagName == 'SPAN'){
        return true;
      }else{
        return false;
      }
    });
  },


  //----------------------------------------------------------------------------
  // Update  Calendar
  //----------------------------------------------------------------------------

  update: function(date) {

    var today      = new Date();
    var thisYear   = today.getFullYear();
    var thisMonth  = today.getMonth();
    var thisDay    = today.getDate();
    var month      = date.getMonth();
    var dayOfMonth = date.getDate();
    var hour       = date.getHours();
    var minute     = date.getMinutes();

    // Ensure date is within the defined range
    if (date.getFullYear() < this.minYear)
      date.__setFullYear(this.minYear);
    else if (date.getFullYear() > this.maxYear)
      date.__setFullYear(this.maxYear);

    if (this.isBackedUp()){
      this.dateBackedUp = new Date(date);
    }else{
      this.date = new Date(date);
    }

    // Calculate the first day to display (including the previous month)
    date.setDate(1)
    date.setDate(-(date.getDay()) + 1)

    // Fill in the days of the month
    Element.getElementsBySelector(this.container, 'tbody tr').each(
      function(row, i) {
        var rowHasDays = false;
        row.immediateDescendants().each(
          function(cell, j) {
            var day            = date.getDate();
            var dayOfWeek      = date.getDay();
            var isCurrentMonth = (date.getMonth() == month);

            // Reset classes on the cell
            cell.className = '';
            cell.date = new Date(date);
            cell.update(day);

            // Account for days of the month other than the current month
            if (!isCurrentMonth)
              cell.addClassName('otherDay');
            else
              rowHasDays = true;

            // Ensure the current day is selected
            if ((! this.isBackedUp()) && isCurrentMonth && day == dayOfMonth) {
              cell.addClassName('selected');
              this.currentDateElement = cell;
            }

            // Today
            if (date.getFullYear() == thisYear && date.getMonth() == thisMonth && day == thisDay)
              cell.addClassName('today');

            // Weekend
            if ([0, 6].indexOf(dayOfWeek) != -1)
              cell.addClassName('weekend');

            // Set the date to tommorrow
            date.setDate(day + 1);
          }.bind(this)
        )
        // Hide the extra row if it contains only days from another month
        !rowHasDays ? row.hide() : row.show();
      }.bind(this)
    )

    Element.getElementsBySelector(this.container, 'tfoot tr td select').each(
      function(sel){
        if(sel.name == 'hourSelect'){
          sel.selectedIndex = hour;
        }else if(sel.name == 'minuteSelect'){
          if (this.minuteStep == 1){
            sel.selectedIndex = minute;
          }else{
            sel.selectedIndex = this.findClosestMinute(minute);
          }
        }
      }.bind(this)
    )

    this.container.getElementsBySelector('td.title')[0].update(
      Calendar.MONTH_NAMES[month] + ' ' + this.dateOrDateBackedUp().getFullYear()
    )

  },


  findClosestMinute:  function(val){
    if (val == 0){
      return 0;
    }
    var lowest = ((val / this.minuteStep).floor() * this.minuteStep);
    var distance = val % this.minuteStep;
    var minuteValueToShow;

    if (distance <= (this.minuteStep / 2)){
      minuteValueToShow = lowest;
    }else{
      minuteValueToShow = lowest + this.minuteStep;
    }

    if (minuteValueToShow == 0){
      return minuteValueToShow;
    }else if(minuteValueToShow >= 60){
      return (minuteValueToShow / this.minuteStep).floor() - 1;
    }else{
      return minuteValueToShow / this.minuteStep;
    }
  },

  _drawButtonCell: function(parentForCell, text, colSpan, navAction) {
    var cell          = new Element('td');
    if (colSpan > 1) cell.colSpan = colSpan;
    cell.className    = 'cvbutton';
    cell.calendar     = this;
    cell.navAction    = navAction;
    cell.innerHTML    = text;
    cell.unselectable = 'on'; // IE
    parentForCell.appendChild(cell);
    return cell;
  },


  //------------------------------------------------------------------------------
  // Calendar Display Functions
  //------------------------------------------------------------------------------

  show: function(){
    this.container.show();
    if (this.isPopup) {
      if (this.hideOnClickElsewhere){
        window._popupCalendar = this;
        document.observe('mousedown', Calendar._checkCalendar);
      }
    }
  },

  showAt: function (x, y) {
    this.container.setStyle({ left: x + 'px', top: y + 'px' });
    this.show();
  },


  showAtElement: function(event, element) {
    this.container.show();
    var x, y;
    if (this.popupPositioningStrategy == 'pointer'){ // follow the mouse pointer
      var pos = Event.pointer(event);
      var containerWidth = this.container.getWidth();
      x = containerWidth * this.x + pos.x;
      y = containerWidth * this.y + pos.y;
    }else{ // 'container' - container of the trigger elements
      var pos = Position.cumulativeOffset(element);
      x = pos[0];
      y = this.container.offsetHeight * 0.75 + pos[1];
    }
    this.showAt(x, y);
  },

  hide: function() {
    if (this.isPopup){
      Event.stopObserving(document, 'mousedown', Calendar._checkCalendar);
    }
    this.container.hide();
    this.onHideCallback(this.date, this);
  },


  // Tries to identify the date represented in a string.  If successful it also
  // calls this.updateIfDateDifferent which moves the calendar to the given date.
  parseDate: function(str, format){
    if (!format){
      format = this.dateFormat;
    }
    var res = Date.parseDate(str, format);
    return res;
  },


  dateOrDateBackedUp: function(){
    return this.date || this.dateBackedUp;
  },

  updateIfDateDifferent: function(date) {
    if (!date.equalsTo(this.dateOrDateBackedUp())){
      this.update(date);
    }
  },

  backupDateAndCurrentElement: function(){
    if (this.minuteSelect){
      this.minuteSelect.disable();
    }
    if (this.hourSelect){
      this.hourSelect.disable();
    }

    this.currentDateElementBackedUp = this.currentDateElement;
    this.currentDateElement = null;

    this.dateBackedUp = this.date;
    this.date = null;
  },

  restoreDateAndCurrentElement: function(){
    if (this.minuteSelect){
      this.minuteSelect.enable();
    }
    if (this.hourSelect){
      this.hourSelect.enable();
    }

    this.currentDateElement = this.currentDateElementBackedUp;
    this.currentDateElementBackedUp = null;

    this.date = this.dateBackedUp;
    this.dateBackedUp = null;
  },

  isBackedUp: function(){
    return ((this.date == null) && this.dateBackedUp);
  },

  dumpDates: function(){
    console.log('date: ' + this.date);
    console.log('dateBackedUp: ' + this.dateBackedUp);
  },


  setRange: function(minYear, maxYear) {
    this.minYear = minYear;
    this.maxYear = maxYear;
  }
})

// Delete or add new locales from I18n.js according to your needs
Calendar.messagebundle = $H({'en' :
  $H({
    'monday' : 'Monday',
    'tuesday' : 'Tuesday',
    'wednesday' : 'Wednesday',
    'thursday' : 'Thursday',
    'friday' : 'Friday',
    'saturday' : 'Saturday',
    'sunday' : 'Sunday',

    'monday_short' : 'M',
    'tuesday_short' : 'T',
    'wednesday_short' : 'W',
    'thursday_short' : 'T',
    'friday_short' : 'F',
    'saturday_short' : 'S',
    'sunday_short' : 'S',

    'january' : 'January',
    'february' : 'February',
    'march' : 'March',
    'april' : 'April',
    'may' : 'May',
    'june' : 'June',
    'july'  : 'July',
    'august' : 'August',
    'september'  : 'September',
    'october' : 'October',
    'november' : 'November',
    'december' : 'December',

    'january_short' : 'Jan',
    'february_short' : 'Feb',
    'march_short' : 'Mar',
    'april_short' : 'Apr',
    'may_short' : 'May',
    'june_short' : 'Jun',
    'july_short'  : 'Jul',
    'august_short' : 'Aug',
    'september_short'  : 'Sep',
    'october_short' : 'Oct',
    'november_short' : 'Nov',
    'december_short' : 'Dec',

    'today' : 'Today'
  }),
  'fr' :
    $H({
      'monday' : 'Lundi',
      'tuesday' : 'Mardi',
      'wednesday' : 'Mercredi',
      'thursday' : 'Jeudi',
      'friday' : 'Vendredi',
      'saturday' : 'Samedi',
      'sunday' : 'Dimanche',

      'monday_short' : 'Lu',
      'tuesday_short' : 'Ma',
      'wednesday_short' : 'Me',
      'thursday_short' : 'Je',
      'friday_short' : 'Ve',
      'saturday_short' : 'Sa',
      'sunday_short' : 'Di',

      'january' : 'janvier',
      'february' : 'février',
      'march' : 'mars',
      'april' : 'avril',
      'may' : 'mai',
      'june' : 'juin',
      'july'  : 'juillet',
      'august' : 'août',
      'september'  : 'septembre',
      'october' : 'octobre',
      'november' : 'novembre',
      'december' : 'décembre',

      'january_short' : 'jan',
      'february_short' : 'fév',
      'march_short' : 'mar',
      'april_short' : 'avr',
      'may_short' : 'mai',
      'june_short' : 'jun',
      'july_short'  : 'jul',
      'august_short' : 'aoû',
      'september_short'  : 'sep',
      'october_short' : 'oct',
      'november_short' : 'nov',
      'december_short' : 'dec',

      'today' : 'aujourd\'hui'
    }),
    'nl' :
      $H({
        'monday' : 'maandag',
        'tuesday' : 'dinsdag',
        'wednesday' : 'woensdag',
        'thursday' : 'donderdag',
        'friday' : 'vrijdag',
        'saturday' : 'zaterdag',
        'sunday' : 'zondag',

        'monday_short' : 'Ma',
        'tuesday_short' : 'Di',
        'wednesday_short' : 'Wo',
        'thursday_short' : 'Do',
        'friday_short' : 'Vr',
        'saturday_short' : 'Za',
        'sunday_short' : 'Zo',

        'january' : 'januari',
        'february' : 'februari',
        'march' : 'maart',
        'april' : 'april',
        'may' : 'mei',
        'june' : 'juni',
        'july'  : 'juli',
        'august' : 'augustus',
        'september'  : 'september',
        'october' : 'oktober',
        'november' : 'november',
        'december' : 'december',

        'january_short' : 'jan',
        'february_short' : 'feb',
        'march_short' : 'mrt',
        'april_short' : 'apr',
        'may_short' : 'mei',
        'june_short' : 'jun',
        'july_short'  : 'jul',
        'august_short' : 'aug',
        'september_short'  : 'sep',
        'october_short' : 'okt',
        'november_short' : 'nov',
        'december_short' : 'dec',

        'today' : 'vandaag'
      })
});


Calendar.getMessageFor = function(key){

  var lang = Calendar.language || 'en';
  if (! Calendar.messagebundle.get(lang)){
    lang = 'en';
  }
  return Calendar.messagebundle.get(lang).get(key);
};

Calendar.VERSION = '1.4';

Calendar.defaultDateFormat = '%Y-%m-%d';
Calendar.defaultDateTimeFormat = '%Y-%m-%d %H:%M';

// we need to postpone the initialization of these structures to let the page define the language of the page
Calendar.init =  function(){

  Calendar.DAY_NAMES = new Array(
    Calendar.getMessageFor('monday'),
    Calendar.getMessageFor('tuesday'),
    Calendar.getMessageFor('wednesday'),
    Calendar.getMessageFor('thursday'),
    Calendar.getMessageFor('friday'),
    Calendar.getMessageFor('saturday'),
    Calendar.getMessageFor('sunday')
  );

  Calendar.SHORT_DAY_NAMES = new Array(
    Calendar.getMessageFor('monday_short'),
    Calendar.getMessageFor('tuesday_short'),
    Calendar.getMessageFor('wednesday_short'),
    Calendar.getMessageFor('thursday_short'),
    Calendar.getMessageFor('friday_short'),
    Calendar.getMessageFor('saturday_short'),
    Calendar.getMessageFor('sunday_short')
  );

  Calendar.MONTH_NAMES = new Array(
    Calendar.getMessageFor('january'),
    Calendar.getMessageFor('february'),
    Calendar.getMessageFor('march'),
    Calendar.getMessageFor('april'),
    Calendar.getMessageFor('may'),
    Calendar.getMessageFor('june'),
    Calendar.getMessageFor('july'),
    Calendar.getMessageFor('august'),
    Calendar.getMessageFor('september'),
    Calendar.getMessageFor('october'),
    Calendar.getMessageFor('november'),
    Calendar.getMessageFor('december')
  );

  Calendar.SHORT_MONTH_NAMES = new Array(
    Calendar.getMessageFor('january_short'),
    Calendar.getMessageFor('february_short'),
    Calendar.getMessageFor('march_short'),
    Calendar.getMessageFor('april_short'),
    Calendar.getMessageFor('may_short'),
    Calendar.getMessageFor('june_short'),
    Calendar.getMessageFor('july_short'),
    Calendar.getMessageFor('august_short'),
    Calendar.getMessageFor('september_short'),
    Calendar.getMessageFor('october_short'),
    Calendar.getMessageFor('november_short'),
    Calendar.getMessageFor('december_short')
  );
  Calendar.init_done = true;
};

Calendar.NAV_PREVIOUS_YEAR  = -2;
Calendar.NAV_PREVIOUS_MONTH = -1;
Calendar.NAV_TODAY          =  0;
Calendar.NAV_NEXT_MONTH     =  1;
Calendar.NAV_NEXT_YEAR      =  2;

//------------------------------------------------------------------------------
// Static Methods
//------------------------------------------------------------------------------

// This gets called when the user presses a mouse button anywhere in the
// document, if the calendar is shown. If the click was outside the open
// calendar this function closes it.
Calendar._checkCalendar = function(event) {
  if (!window._popupCalendar){
    return false;
  }
  if (Element.descendantOf(Event.element(event), window._popupCalendar.container)){
    return;
  }
  Calendar.closeHandler(window._popupCalendar);
  return Event.stop(event);
}

//------------------------------------------------------------------------------
// Event Handlers
//------------------------------------------------------------------------------

Calendar.handleMouseDownEvent = function(event){
  if (event.element().type == 'select-one'){ // ignore select elements - not escaping this in Safari leaves select boxes non-functional
    return true;
  }
  Event.observe(document, 'mouseup', Calendar.handleMouseUpEvent);
  Event.stop(event)
}

Calendar.handleMouseUpEvent = function(event){
  var el        = Event.element(event);
  var calendar  = el.calendar;
  var isNewDate = false;


  // If the element that was clicked on does not have an associated Calendar
  // object, return as we have nothing to do.
  if (!calendar) return false;

  // Clicked on a day
  if (typeof el.navAction == 'undefined') {

    var dateWasDefined = true;
    if (calendar.date == null){
      dateWasDefined = false;
      calendar.restoreDateAndCurrentElement();
    }


    if (calendar.currentDateElement) {
      Element.removeClassName(calendar.currentDateElement, 'selected');

      if (dateWasDefined && el == calendar.currentDateElement){
        calendar.backupDateAndCurrentElement();

        calendar.updateOuterField();

        Event.stopObserving(document, 'mouseup', Calendar.handleMouseUpEvent);
        return Event.stop(event);
      }

      Element.addClassName(el, 'selected');

      calendar.shouldClose = (calendar.currentDateElement == el);

      if (!calendar.shouldClose) {

        calendar.currentDateElement = el;
      }
    }
    calendar.date.setDateOnly(el.date);
    isNewDate = true;

    calendar.shouldClose = !el.hasClassName('otherDay');


    var isOtherMonth     = !calendar.shouldClose;
    if (isOtherMonth) {
      calendar.update(calendar.date);
    }

    if (! calendar.hideOnClickOnDay){ // override closing if calendar.hideOnClickOnDay is false
      calendar.shouldClose = false;
    }

  } else { // Clicked on an action button

    var date = new Date(calendar.dateOrDateBackedUp());

    if (el.navAction == Calendar.NAV_TODAY){
      date.setDateOnly(new Date());
    }

    var year = date.getFullYear();
    var mon = date.getMonth();

    function setMonth(m) {
      var day = date.getDate();
      var max = date.getMonthDays(m);
      if (day > max) date.setDate(max);
      date.setMonth(m);
    }

    switch (el.navAction) {

      // Previous Year
      case Calendar.NAV_PREVIOUS_YEAR:
        if (year > calendar.minYear)
          date.__setFullYear(year - 1);
        break;

      // Previous Month
      case Calendar.NAV_PREVIOUS_MONTH:
        if (mon > 0) {
          setMonth(mon - 1);
        }
        else if (year-- > calendar.minYear) {
          date.__setFullYear(year);
          setMonth(11);
        }
        break;

      // Today
      case Calendar.NAV_TODAY:
        break;

      // Next Month
      case Calendar.NAV_NEXT_MONTH:
        if (mon < 11) {
          setMonth(mon + 1);
        }else if (year < calendar.maxYear) {
          date.__setFullYear(year + 1);
          setMonth(0);
        }
        break;

      // Next Year
      case Calendar.NAV_NEXT_YEAR:
        if (year < calendar.maxYear){
          date.__setFullYear(year + 1);
        }
        break;
    }

    if (!date.equalsTo(calendar.dateOrDateBackedUp())) {
      calendar.updateIfDateDifferent(date);
      isNewDate = true;
    } // else if (el.navAction == 0) {
    //   isNewDate = (calendar.shouldClose = true);
    // } // Hm, what did I mean with this code?
  }

  if (isNewDate && event) {
    Calendar.selectHandler(calendar);
  }

  if (calendar.shouldClose && event) {
    Calendar.closeHandler(calendar);
  }

  Event.stopObserving(document, 'mouseup', Calendar.handleMouseUpEvent);
  return Event.stop(event);
}

Calendar.selectHandler = function(calendar){

  // Update dateField value
  calendar.updateOuterField();


  // Call the close handler, if necessary
  if (calendar.shouldClose) {
    Calendar.closeHandler(calendar);
  }
}

Calendar.closeHandler = function(calendar){
  calendar.hide();
  calendar.shouldClose = false;
}



// global object that remembers the calendar
window._popupCalendar = null;


//==============================================================================
//
// Date Object Patches
//
// This is pretty much untouched from the original. I really would like to get
// rid of these patches if at all possible and find a cleaner way of
// accomplishing the same things. It's a shame Prototype doesn't extend Date at
// all.
//
//==============================================================================

Date.DAYS_IN_MONTH = new Array(31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31)
Date.SECOND        = 1000 /* milliseconds */
Date.MINUTE        = 60 * Date.SECOND
Date.HOUR          = 60 * Date.MINUTE
Date.DAY           = 24 * Date.HOUR
Date.WEEK          =  7 * Date.DAY

// Parses Date
Date.parseDate = function(str, fmt) {
  if (str){
    str = new String(str);
  }else{
    str = new String('');
  }
  str = str.strip();

  var today = new Date();
  var y     = 0;
  var m     = -1;
  var d     = 0;
  var a     = str.split(/\W+/);
  var b     = fmt.match(/%./g);
  var i     = 0, j = 0;
  var hr    = 0;
  var min   = 0;

  for (i = 0; i < a.length; ++i) {
    if (!a[i]) continue;
    switch (b[i]) {
      case "%d":
      case "%e":
        d = parseInt(a[i], 10);
        break;
      case "%m":
        m = parseInt(a[i], 10) - 1;
        break;
      case "%Y":
      case "%y":
        y = parseInt(a[i], 10);
        (y < 100) && (y += (y > 29) ? 1900 : 2000);
        break;
      case "%b":
      case "%B":
        for (j = 0; j < 12; ++j) {
          if (Calendar.MONTH_NAMES[j].substr(0, a[i].length).toLowerCase() == a[i].toLowerCase()) {
            m = j;
            break;
          }
        }
        break;
      case "%H":
      case "%I":
      case "%k":
      case "%l":
        hr = parseInt(a[i], 10);
        break;
      case "%P":
      case "%p":
        if (/pm/i.test(a[i]) && hr < 12)
          hr += 12;
        else if (/am/i.test(a[i]) && hr >= 12)
          hr -= 12;
        break;
      case "%M":
        min = parseInt(a[i], 10);
        break;
    }
  }
  if (isNaN(y)) y = today.getFullYear();
  if (isNaN(m)) m = today.getMonth();
  if (isNaN(d)) d = today.getDate();
  if (isNaN(hr)) hr = today.getHours();
  if (isNaN(min)) min = today.getMinutes();
  if (y != 0 && m != -1 && d != 0)
    return new Date(y, m, d, hr, min, 0);
  y = 0; m = -1; d = 0;
  for (i = 0; i < a.length; ++i) {
    if (a[i].search(/[a-zA-Z]+/) != -1) {
      var t = -1;
      for (j = 0; j < 12; ++j) {
        if (Calendar.MONTH_NAMES[j].substr(0, a[i].length).toLowerCase() == a[i].toLowerCase()) { t = j; break; }
      }
      if (t != -1) {
        if (m != -1) {
          d = m+1;
        }
        m = t;
      }
    } else if (parseInt(a[i], 10) <= 12 && m == -1) {
      m = a[i]-1;
    } else if (parseInt(a[i], 10) > 31 && y == 0) {
      y = parseInt(a[i], 10);
      (y < 100) && (y += (y > 29) ? 1900 : 2000);
    } else if (d == 0) {
      d = a[i];
    }
  }
  if (y == 0)
    y = today.getFullYear();
  if (m != -1 && d != 0)
    return new Date(y, m, d, hr, min, 0);
  return today;
};

// Returns the number of days in the current month
Date.prototype.getMonthDays = function(month) {
  var year = this.getFullYear()
  if (typeof month == "undefined")
    month = this.getMonth()
  if (((0 == (year % 4)) && ( (0 != (year % 100)) || (0 == (year % 400)))) && month == 1)
    return 29
  else
    return Date.DAYS_IN_MONTH[month]
};

// Returns the number of day in the year
Date.prototype.getDayOfYear = function() {
  var now = new Date(this.getFullYear(), this.getMonth(), this.getDate(), 0, 0, 0);
  var then = new Date(this.getFullYear(), 0, 0, 0, 0, 0);
  var time = now - then;
  return Math.floor(time / Date.DAY);
};

/** Returns the number of the week in year, as defined in ISO 8601. */
Date.prototype.getWeekNumber = function() {
  var d = new Date(this.getFullYear(), this.getMonth(), this.getDate(), 0, 0, 0);
  var DoW = d.getDay();
  d.setDate(d.getDate() - (DoW + 6) % 7 + 3); // Nearest Thu
  var ms = d.valueOf(); // GMT
  d.setMonth(0);
  d.setDate(4); // Thu in Week 1
  return Math.round((ms - d.valueOf()) / (7 * 864e5)) + 1;
};

/** Checks date and time equality */
Date.prototype.equalsTo = function(date) {
  return ((this.getFullYear() == date.getFullYear()) &&
   (this.getMonth() == date.getMonth()) &&
   (this.getDate() == date.getDate()) &&
   (this.getHours() == date.getHours()) &&
   (this.getMinutes() == date.getMinutes()));
};

/** Set only the year, month, date parts (keep existing time) */
Date.prototype.setDateOnly = function(date) {
  var tmp = new Date(date);
  this.setDate(1);
  this.__setFullYear(tmp.getFullYear());
  this.setMonth(tmp.getMonth());
  this.setDate(tmp.getDate());
};

/** Prints the date in a string according to the given format. */
Date.prototype.print = function (str) {
  var m = this.getMonth();
  var d = this.getDate();
  var y = this.getFullYear();
  var wn = this.getWeekNumber();
  var w = this.getDay();
  var s = {};
  var hr = this.getHours();
  var pm = (hr >= 12);
  var ir = (pm) ? (hr - 12) : hr;
  var dy = this.getDayOfYear();
  if (ir == 0)
    ir = 12;
  var min = this.getMinutes();
  var sec = this.getSeconds();
  s["%a"] = Calendar.SHORT_DAY_NAMES[w]; // abbreviated weekday name [FIXME: I18N]
  s["%A"] = Calendar.DAY_NAMES[w]; // full weekday name
  s["%b"] = Calendar.SHORT_MONTH_NAMES[m]; // abbreviated month name [FIXME: I18N]
  s["%B"] = Calendar.MONTH_NAMES[m]; // full month name
  // FIXME: %c : preferred date and time representation for the current locale
  s["%C"] = 1 + Math.floor(y / 100); // the century number
  s["%d"] = (d < 10) ? ("0" + d) : d; // the day of the month (range 01 to 31)
  s["%e"] = d; // the day of the month (range 1 to 31)
  // FIXME: %D : american date style: %m/%d/%y
  // FIXME: %E, %F, %G, %g, %h (man strftime)
  s["%H"] = (hr < 10) ? ("0" + hr) : hr; // hour, range 00 to 23 (24h format)
  s["%I"] = (ir < 10) ? ("0" + ir) : ir; // hour, range 01 to 12 (12h format)
  s["%j"] = (dy < 100) ? ((dy < 10) ? ("00" + dy) : ("0" + dy)) : dy; // day of the year (range 001 to 366)
  s["%k"] = hr;   // hour, range 0 to 23 (24h format)
  s["%l"] = ir;   // hour, range 1 to 12 (12h format)
  s["%m"] = (m < 9) ? ("0" + (1+m)) : (1+m); // month, range 01 to 12
  s["%M"] = (min < 10) ? ("0" + min) : min; // minute, range 00 to 59
  s["%n"] = "\n";   // a newline character
  s["%p"] = pm ? "PM" : "AM";
  s["%P"] = pm ? "pm" : "am";
  // FIXME: %r : the time in am/pm notation %I:%M:%S %p
  // FIXME: %R : the time in 24-hour notation %H:%M
  s["%s"] = Math.floor(this.getTime() / 1000);
  s["%S"] = (sec < 10) ? ("0" + sec) : sec; // seconds, range 00 to 59
  s["%t"] = "\t";   // a tab character
  // FIXME: %T : the time in 24-hour notation (%H:%M:%S)
  s["%U"] = s["%W"] = s["%V"] = (wn < 10) ? ("0" + wn) : wn;
  s["%u"] = w + 1;  // the day of the week (range 1 to 7, 1 = MON)
  s["%w"] = w;    // the day of the week (range 0 to 6, 0 = SUN)
  // FIXME: %x : preferred date representation for the current locale without the time
  // FIXME: %X : preferred time representation for the current locale without the date
  s["%y"] = ('' + y).substr(2, 2); // year without the century (range 00 to 99)
  s["%Y"] = y;    // year with the century
  s["%%"] = "%";    // a literal '%' character

  return str.gsub(/%./, function(match) { return s[match] || match });
};


Date.prototype.__setFullYear = function(y) {
  var d = new Date(this);
  d.setFullYear(y);
  if (d.getMonth() != this.getMonth())
    this.setDate(28);
  this.setFullYear(y);
};

