'use strict';

/* Return TRUE/FALSE base on windows size.
========================================================================== */
var isSmallScreen = function isSmallScreen() {
  return window.innerWidth <= 1260;
};

/* ==========================================================================
  Collapse funtionality
  ========================================================================== */
var collapseSidebarOnSmallScreen = function collapseSidebarOnSmallScreen() {
  if (isSmallScreen()) {
    // in small screen the menu starts collapsed
    $('.js-main-menu').addClass('collapsed-sidebar');
    $('.js-footer-content').addClass('display-collapsed');
    // return true to initiate the tooltip
    window.localStorage.setItem('collapsedSidebar', $('.js-main-menu').hasClass('collapsed-sidebar'));
    return true;
  }
};

var collapseSidebarBasedOnLocalStorage = function collapseSidebarBasedOnLocalStorage() {
  if (window.localStorage.getItem('collapsedSidebar') === 'true') {
    // if saved in locastorage that collapsedSidebar=true, menu starts collapsed
    $('.js-main-menu').addClass('collapsed-sidebar');
    // return true to initiate the tooltip
    return true;
  }
};

var toggleSidebarAndSave = function toggleSidebarAndSave() {
  $('.js-main-menu').toggleClass('collapsed-sidebar');
  $('.js-footer-content').toggleClass('display-collapsed');

  toggleTooltip();

  if (!isSmallScreen()) {
    saveSidebarState();
  }
};

var autoToggleSidebar = function autoToggleSidebar() {
  var shouldCollapse = isSmallScreen() || window.localStorage.getItem('collapsedSidebar') === 'true';

  toggleTooltip();

  $('.js-main-menu').toggleClass('collapsed-sidebar', shouldCollapse);
  $('.js-footer-content').toggleClass('display-collapsed', shouldCollapse);
};

var saveSidebarState = function saveSidebarState() {
  window.localStorage.setItem('collapsedSidebar', $('.js-main-menu').hasClass('collapsed-sidebar'));
};

// Initiate or destroy the tooltip according to the state of the collapsible menu
var toggleTooltip = function toggleTooltip() {
  // if the menu is not collapsed (meaning, it is open) we dont need to show the tooltips
  if ($('.collapsed-sidebar').length === 0) {
    $('.js-sidebar-tooltip').attr('data-original-title', 'Collapse menu');
  } else {
    // If sidebar is collapsed update sidebar toggle btn tooltip title
    $('.js-sidebar-tooltip').attr('data-original-title', 'Open menu');
  }
};

// Togle on resize and click.
$(window).resize(autoToggleSidebar);
$(document).on('click', '.js-sidebar-toggle', toggleSidebarAndSave);

// When the page is done loading, check if we should toggle the menu based on width or localstorage
$(document).ready(function () {
  if (window.localStorage.getItem('collapsedSidebar') === 'true') {
    // Always display content-footer if showSidebar === false
    $('.js-footer-content').addClass('display-collapsed');
    // If sidebar is collapsed update sidebar toggle btn tooltip title
    $('.js-sidebar-tooltip').attr('data-original-title', 'Open menu');
  }
  // If sidebar isn't collapsed update sidebar toggle btn tooltip title
  if (window.localStorage.getItem('collapsedSidebar') === 'false') {
    $('.js-sidebar-tooltip').attr('data-original-title', 'Collapse menu');
  }

  // if either the screen is small or it is saved in localstorage to keep the menu open
  // then we Initiate the tooltip
  if (collapseSidebarOnSmallScreen() || collapseSidebarBasedOnLocalStorage()) {
    toggleTooltip();
  }

  /* ==========================================================================
  Menu collapse funtionality for mobile
  ========================================================================== */
  /* Select the mobile menu elements */
  var mobileMenu = $('.js-mobile-menu').find('nav');
  /* Toggle mobile menu on click */
  $('.js-burger-menu').click(function () {
    mobileMenu.slideToggle();
    $('body').toggleClass('mobile-menu-open');
  });

  showCollpasedMenuFloatingItems();
});

var showCollpasedMenuFloatingItems = function showCollpasedMenuFloatingItems() {
  $('.menu-item').on('mouseover', function () {
    var $menuItem = $(this);
    var $collapsedTitle = $('> .menu-element', $menuItem);

    var menuItemPos = $menuItem.position();

    // nav height to position dropdown menu from bottom
    var navHeight = $('.nav-wrap').height();
    var finalDropdownPos = navHeight - menuItemPos.top;

    // Dropdown height and calculate bottom height + extra px for margin
    var windowHeight = $('.main-menu').height();
    var dropdownHeight = $('> .menu-element', $menuItem).height();
    var bottomHeight = Math.round(windowHeight - menuItemPos.top) - 70;

    if (dropdownHeight < bottomHeight) {
      $collapsedTitle.css({
        bottom: 'auto',
        top: menuItemPos.top,
        left: $menuItem.hasClass('menu-dropdown') ? menuItemPos.left + Math.round($menuItem.outerWidth() * 1) : 0
      });
    } else {
      $collapsedTitle.css({
        bottom: $menuItem.hasClass('menu-dropdown') ? finalDropdownPos - 37 : finalDropdownPos,
        top: 'auto',
        left: $menuItem.hasClass('menu-dropdown') ? menuItemPos.left + Math.round($menuItem.outerWidth() * 1) : 0
      });
    }
  });
};

$(function () {
  /* Menu elements limit, we need to pass it here for the resize event to work */
  var limit = $(window).innerWidth > 1300 ? 7 : 4;
  /* When window is resized, run our collapse function */
  $(window).resize(submenuCollapse(limit));
  /* On scroll, call submenuAddShadow */
  $(document).scroll(submenuAddShadow);
  /* When window loads, if current the page is inside the dropdown, then highlight more menu */
  submenuCollapse();

  $('.js-sidebar-toggle').click(function () {
    submenuCollapse();
  });
});

/* ==========================================================================
  Menu collapse function
  ========================================================================== */
/* Maximum number of elements allowed in the menu  */

/*
  by default the limit is 7, unless an argument is passed.
  This is necessary to unit test this component
*/
var submenuCollapse = function submenuCollapse() {
  var limit = arguments.length > 0 && arguments[0] !== undefined ? arguments[0] : 7;

  /* Highlight more menu, if current the page is inside the dropdown */
  highlightMoreMenu();

  /* Get each nav element's width and set it as attribute to be used later */
  submenuLinksSetAttribute();

  /* Display dropdown in left/right based on windows size */
  submenuDropdownPosition();

  var collapsedSidebarStatus = $('.js-main-menu').hasClass('collapsed-sidebar');

  var submenuLimit = limit;
  var submenuLinks = $('.js-submenu-visible > .js-select-current');
  var submenuMore = $('.js-submenu-more');

  var navWidth = 0;
  var submenuMoreContent = $('.js-submenu-more-list');
  var submenuWidth = $('.js-submenu-section').width();
  var submenuLinksCheck = void 0;

  if (collapsedSidebarStatus && $(window).innerWidth() > 754) {
    submenuWidth = submenuWidth - 190;
  }

  /* Cleanup dom when resizing */
  submenuMoreContent.html('');

  /* 'smart' responsiveness */
  submenuLinks.each(function (index) {
    // Use the width data attr we setup before
    navWidth += $(this).data('width');

    // Possible combination of elements
    var moreSearchWidth = $('.js-submenu-more').outerWidth() + $('.submenu-search').outerWidth();
    var moreUserWidth = $('.js-submenu-more').outerWidth() + $('.js-user-profile').outerWidth();
    var combinedWidth = $('.js-submenu-more').outerWidth() + $('.submenu-search').outerWidth() + $('.js-user-profile').outerWidth();

    // Cache conditions for readability
    var condLimit = index > submenuLimit - 1;
    // Default condition (no search or user)
    var condDefault = navWidth > submenuWidth - 70;
    // More dropdown & search
    var condMoreSearch = navWidth > submenuWidth - moreSearchWidth;
    // More dropdown & user
    var condMoreUser = navWidth > submenuWidth - moreUserWidth;
    // All dropdowns
    var condCombined = navWidth > submenuWidth - combinedWidth;

    // If any of these conditions are met
    if (condLimit || condDefault || condMoreSearch || condMoreUser || condCombined) {
      // Hide the nav item
      $(this).addClass('d-none');
      // Clone it, strip it from any class and move it to the dropdown
      $(this).clone().removeClass('d-none submenu-item').addClass('dropdown-item').appendTo(submenuMoreContent);
      // Show the dropdown
      submenuMore.show();
      submenuLinksCheck = true;
    } else {
      // If none of these conditions are met, ensure that we show the nav items
      $(this).removeClass('d-none');
    }
  });

  // If the amount of nav items is greater than 7 or check if all conditions are met, display the dropdown
  if (submenuLinks.length > submenuLimit || submenuLinksCheck) {
    submenuMore.show();
  } else {
    submenuMore.hide();
  }
};

var submenuDropdownPosition = function submenuDropdownPosition() {
  var _selector = $('.js-submenu-section').innerWidth();

  return _selector <= 1360 ? $('.js-submenu-content').removeClass('dropdown-menu-left').addClass('dropdown-menu-right') : $('.js-submenu-content').removeClass('dropdown-menu-right').addClass('dropdown-menu-left');
};

/* Add data-width attr to navigation elements  */
function submenuLinksSetAttribute() {
  $('.js-submenu-visible > .js-select-current').each(function () {
    $(this).attr('data-width', $(this).outerWidth());
  });
}

/* Add shadow to submenu element on scrop */
var submenuAddShadow = function submenuAddShadow() {
  if ($(window).scrollTop() > 100) {
    $('.js-submenu-section').stop().addClass('submenu-scroll');
  } else {
    $('.js-submenu-section').stop().removeClass('submenu-scroll');
  }
};

/* When window loads, if current the page is inside the dropdown, then highlight more menu */
var highlightMoreMenu = function highlightMoreMenu() {
  var $selectedSubItem = $('.js-submenu-more-list').find('.selected').length;
  if ($selectedSubItem === 1) {
    $('.js-submenu-more .submenu-item').addClass('selected');
  } else {
    $('.js-submenu-more .submenu-item').removeClass('selected');
  }
};

$(function () {
  /*
    Use this as follows:
    Add the class .js-select-current to the link you want to select
    it will check if `href = path` matches with the current path
    in the URL, and if it does, the item will get the class `.selected`
   */

  $('.js-select-current').addClass(function () {
    var itemRoute = $(this).attr('href');
    var itemRouteNew = window.location.pathname;
    var itemRouteSplit = itemRouteNew.split('/');

    if (itemRouteSplit.length > 3) {
      itemRouteSplit.pop();
    }
    var windowLocation = itemRouteSplit.join('/');
    return windowLocation === itemRoute ? 'selected' : '';
  });

  $('.js-select-submenu').addClass(function () {
    var itemRoute = $(this).attr('href');
    return window.location.pathname === itemRoute ? 'selected' : '';
  });
  /*
    Use this as follows:
    Add the class .js-select-current-parent to the link you want to select.
    It will check if the `href = path` in your item
    matches with parent section of the current path. For example:
    being located at localhost:3000/foo/bar, if your href is `/foo`
    the item will get the class `.selected`, but if the href was `/foo/bar`
    then it will be skipped and not be selected.
   */
  $('.js-select-current-parent').addClass(function () {
    var itemRoute = $(this).attr('href').replace('/', '');
    var currentRoute = window.location.pathname;
    var currentRouteParent = currentRoute.split('/');
    return itemRoute === currentRouteParent[1] ? 'selected' : '';
  });

  makeSubmenuSectionVisible(submenuCollapse, submenuDropdownPosition); // eslint-disable-line no-undef
  $(window).resize(function (fn) {
    makeSubmenuSectionVisible(submenuCollapse, submenuDropdownPosition); // eslint-disable-line no-undef
  });

  // Call the dropdown function
  selectedDropdown();
  selectedDropdownMobile();
});

/*
  Use this as follows:
  Add the class .js-submenu-make-visible to the submenu nav you want to make visible.
  It will check if the `data-parent-menu = path` in the submenu
  matches with parent section of the current path. For example:
  being located at localhost:3000/foo/bar, if your data-parent-menu is `/foo`
  the submenu will become visible, but if the href was `/foo/bar`
  then it will stay hidden.
 */

var makeSubmenuSectionVisible = function makeSubmenuSectionVisible(submenu, submenuDopDown) {
  $('.js-submenu-make-visible').addClass(function () {
    var pm = $(this).data('parent-menu'); // pm => parent menu
    var currentRoute = window.location.pathname;
    var currentRouteParent = currentRoute.split('/');
    var pmSplit = pm.split('/');
    submenuDopDown();
    submenu();

    var newCurrentParent = currentRouteParent.slice(1, 3).join('/');

    if (currentRouteParent.length > 2 && pmSplit.length > 1) {
      return pm === newCurrentParent ? 'visible js-submenu-visible' : '';
    } else {
      return pm === currentRouteParent[1] ? 'visible js-submenu-visible' : '';
    }
  });
};

/* Find if an element inside the menu dropdown list is active and leave the dropdown open */
var selectedDropdown = function selectedDropdown() {
  /* Big screen dropdown open */
  var $selectedSub = $('.menu-dropdown-list').find('a.selected')[0];
  $($selectedSub).parents('.menu-dropdown').addClass('selected');
  $($selectedSub).closest('.menu-dropdown-list').siblings('.js-dropdown-toggle').prop('checked', true);
};

var selectedDropdownMobile = function selectedDropdownMobile() {
  /* Mobile dropdown open */
  var $menuDropdownMobile = $('.js-mobile-menu .menu-dropdown');
  var $selectedSubMobile = $('.js-mobile-menu .menu-dropdown').find('.selected')[0];

  for (var i = 0; i < $menuDropdownMobile.length; i++) {
    $($selectedSubMobile).parents('.menu-dropdown').addClass('selected');
    $($menuDropdownMobile[i]).find('input').attr('id', 'internal-tools-toggle-mobile-' + i);
    $($menuDropdownMobile[i]).find('label').attr('for', 'internal-tools-toggle-mobile-' + i);
    $($selectedSubMobile).closest('.menu-dropdown-list').siblings('.js-dropdown-toggle').prop('checked', true);
  }
};

/* Tooltip initializer for .js-tooltip
   ========================================================================== */
$(function () {
  $('.js-tooltip').mouseover(function () {
    $(this).tooltip('show');
    $(this).mouseout(function () {
      $(this).tooltip('hide');
    });
  });
});

/**
 * Truncates text bases on given length.
 */
$(function () {
  // How to use it: if you have an element with some text and you want to truncate it, add (data-truncate-characters=NUMBER).
  textTruncate();
});

var textTruncate = function textTruncate() {
  // Checks the page for content to truncate
  var charactersSelector = $('[data-truncate-characters]');
  var pixelsSelector = $('[data-truncate-px]');

  // For each founded element, call the truncate function
  for (var i = 0; i < charactersSelector.length; i++) {
    truncateAtCharacter({ selector: $('[data-truncate-characters]')[i] });
  }

  for (var _i = 0; _i < pixelsSelector.length; _i++) {
    truncateAtPixels({ selector: $('[data-truncate-px]')[_i] });
  }
};

var truncateAtCharacter = function truncateAtCharacter(params) {
  var selector = params.selector;


  var truncateLength = selector.getAttribute('data-truncate-characters');
  var initText = selector.textContent.trim();

  /* Add the tooltip content */
  addTooltipBeforeTruncate({ selector: selector });

  var truncateText = selector.textContent = initText.trunc(truncateLength);
  return truncateText;
};

var truncateAtPixels = function truncateAtPixels(params) {
  var selector = params.selector;


  if (selector.innerText.length <= 0) return;

  var limitWidth = selector.getAttribute('data-truncate-px');
  addTooltipBeforeTruncate({ selector: selector });

  return selector.setAttribute('style', '\n    max-width: ' + limitWidth + 'px;\n    overflow: hidden;\n    text-overflow: ellipsis;\n    white-space: nowrap;\n    display: inline-block;\n ');
};

/* Adds the tooltip to title before truncating the text content */
var addTooltipBeforeTruncate = function addTooltipBeforeTruncate(params) {
  var selector = params.selector;


  if (selector.innerText.length <= 0) return;

  selector.setAttribute('title', selector.textContent.trim());
  selector.setAttribute('data-toggle', 'tooltip');
};

/* String method to truncate a string at given value (n) */
// eslint-disable-next-line
String.prototype.trunc = String.prototype.trunc || function (n) {
  // eslint-disable-next-line
  return this.length > n ? this.substring(0, n - 3) + '...' : this;
};
