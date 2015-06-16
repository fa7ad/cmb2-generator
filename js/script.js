/**
 * @author: Hasin Hayder
 * @date: June 14, 2015 4:05 AM
 * @license: MIT
 */
(function ( $ ) {
  var dirty = 0;
  var elements = {};
  $( document ).ready( function () {
    $( '#fields' ).trigger( 'reset' ).on( 'click loadTrig', function () {
      if ( $( '.form-element' ).length < 2 ) {
        $( '.form-element:first .remove' ).attr( 'disabled', '' );
      }
    } ).trigger( 'loadTrig' ).on( 'click', '.add-more', function ( e ) {
      dirty =
        1;
      $( this ).parents( '.form-element' ).find( '.remove' ).removeAttr( 'disabled' );
      e.preventDefault();
      $( this ).parents( ".form-element" ).clone().appendTo( "#fields" ).find( '.option-param' ).remove();
      $( this ).parents( '.btn-group-lg' ).removeClass( 'btn-group' );
      $( this ).hide();
    } ).on( 'click', '.remove', function ( e ) {
      e.preventDefault();
      if ( confirm( "Are you sure to delete?" ) ) {
        $( this ).parents( ".form-element" ).remove();
        $( '.btn-group-lg' ).each(function(){
          $( this ).addClass( 'btn-group' );
        });
        $( "#fields .form-element:last" ).find( ".add-more" ).show();
      }
    } ).on( 'click', '.move-up', function ( e ) {
      e.preventDefault();
      var fe = $( this ).parents( ".form-element" );
      var prevfe = $( fe ).prev( ".form-element" );
      if ( prevfe.length > 0 ) {
        fe.detach();
        fe.insertBefore( prevfe );
        fe.find( ".add-more" ).hide();
        $( "#fields .form-element:last" ).find( ".add-more" ).show();
      }
    } ).on( 'click', '.move-down', function ( e ) {
      e.preventDefault();
      var fe = $( this ).parents( ".form-element" );
      var nextfe = $( fe ).next( ".form-element" );
      if ( nextfe.length > 0 ) {
        fe.detach();
        fe.insertAfter( nextfe );
        fe.find( ".add-more" ).hide();
        $( "#fields .form-element" ).find( ".add-more" ).hide();
        $( "#fields .form-element:last" ).find( ".add-more" ).show();
      }
    } ).on( 'change', '.mb_field_type', function () {
      var dropdown = $( this ), selected_option = dropdown.val(),
        form_elem = dropdown.parents( '.form-element' ),
        html_element = $( '#option-param-elem' ).children(),
        field_types = [ 'multicheck',
          'multicheck_inline',
          'radio',
          'radio_inline',
          'select' ], position_in_array = $.inArray( selected_option,
          field_types ), has_option_elem = form_elem.has( '.option-param' ).length;

      if ( position_in_array >= 0 && !has_option_elem ) {
        html_element.clone().appendTo( form_elem );
      } else if ( position_in_array < 0 && has_option_elem ) {
        form_elem.find( '.option-param' ).remove();
      }

    } ).on( 'change', '.opt-param-type', function () {
      var dropdown = $( this ), type = dropdown.val(), form_elem = dropdown.parents( '.form-element' );

      form_elem.children( '.option-param' ).not( ':first' ).remove().end().find( '[data-opt-type]' ).addClass( 'hidden' ).end().find( '[data-opt-type="' +
      type +
      '"]' ).removeClass( 'hidden' );
    } ).on( 'click', '.opt-move-up', function ( e ) {
      e.preventDefault();

      var current = $( this ).parents( '.option-param' ), prev_elem = current.prev( '.option-param' );

      if ( prev_elem.length ) {
        prev_elem.before( current );
      }
    } ).on( 'click', '.opt-move-down', function ( e ) {
      e.preventDefault();

      var current = $( this ).parents( '.option-param' ), next_elem = current.next( '.option-param' );

      if ( next_elem.length ) {
        next_elem.after( current );
      }
    } ).on( 'click loadTrig', function () {
      if ( $( '.option-param' ).length < 2 ) {
        $( '.option-param:first .opt-remove' ).attr( 'disabled', '' );
      }
    } ).trigger( 'loadTrig' ).on( 'click', '.opt-add', function ( e ) {
      e.preventDefault();
      $( '.opt-remove' ).removeAttr( 'disabled' );
      $( '#option-param-elem' ).children().clone().appendTo( $( this ).parents( '.form-element' ) );
      $( this ).parents( '.btn-group-sm' ).removeClass( 'btn-group' );
    } ).on( 'click', '.opt-remove', function ( e ) {
      e.preventDefault();

      if ( confirm( "Are you sure to delete?" ) ) {
        $( this ).parents( '.option-param' ).remove();
        $( '.btn-group-sm' ).each(function(){
          $( this ).addClass( 'btn-group' );
        });

      }
    } );
    $( ".code-generator" ).on( "click", function ( e ) {
      e.preventDefault();

      elements.mb_id =
        $( "#mb_id" ).val();
      elements.mb_title =
        $( "#mb_title" ).val();
      elements.mb_scope =
        "'" +
        $( "#mb_scope" ).val().split( "," ).join( "','" ).replace( /' /g, "'" ) +
        "'"; //he he
             // :p
      elements.mb_textdomain =
        $( "#mb_textdomain" ).val();
      elements.mb_context =
        $( "#mb_context" ).val();
      elements.mb_priority =
        $( "#mb_priority" ).val();
      elements.mb_function =
        $( "#mb_function" ).val();
      elements.mb_so_key =
        $( "#mb_so_key" ).val();
      elements.mb_so_value =
        $( "#mb_so_value" ).val();

      elements.elements =
        [];
      $( ".form-element" ).each( function () {
        var item = {};
        item.id =
          $( this ).find( ".mb_field_id" ).val();
        item.type =
          $( this ).find( ".mb_field_type" ).val();
        item.title =
          $( this ).find( ".mb_field_title" ).val();
        item.def =
          $( this ).find( ".mb_field_default" ).val();
        item.textdomain =
          elements.mb_textdomain;

        // option param
        if ( $( this ).has( '.option-param' ).length ) {
          item.has_option =
            true;

          var options = $( this ).children( '.option-param' );

          item.option_type =
            options.first().find( '.opt-param-type' ).val();

          if ( 'callback' === item.option_type ) {
            item.option_cb =
              options.first().find( '.opt-callback' ).val();
          } else {
            item.options =
            {};

            options.each( function ( i ) {
              item.options[ i ] =
              {
                key: $( this ).find( '.opt-key' ).val(),
                value: $( this ).find( '.opt-val' ).val(),
                textdomain: elements.mb_textdomain
              }
            } );
          }

        }

        elements.elements.push( item );
      } );

      generateCode( elements );
      dirty =
        0;
    } );

    $( window ).on( 'beforeunload', function () {
      if ( dirty ) {
        return "You have a work in progress!";
      }
    } );

    function generateCode( elements ) {
      var option_arr_elem = "                       \"<%= key %>\" => __( \"<%= value %>\", \"<%= textdomain %>\" ),\n";
      var option_arr = "                    \"options\"   => array(\n" +
        "<%= option_elems %>" + "                     ),\n";
      var option_cb = "                    \"options\"   => \"<%= option_cb %>\"";
      var field = "			array(\n" +
        "					\"name\"    => __( '<%= title %>', '<%= textdomain %>' ),\n" +
        "					\"id\"      =>  \"<%= id %>\",\n" +
        "					\"type\"    => \"<%= type %>\",\n" +
        "					\"default\"    => \"<%= def %>\",\n" +
        "<%= option_param %>         \n" + "               ),\n";
      var metabox = "add_filter( 'cmb2_meta_boxes', '<%= mb_function %>' );\n" +
        "function <%= mb_function %>( array $meta_boxes ) {\n" +
        "   $meta_boxes['<%= mb_id %>'] = array(\n" +
        "       'id'           => '<%= mb_id %>',\n" +
        "       'title'        => __( '<%= mb_title %>', '<%= mb_textdomain %>' ),\n" +
        "       'object_types' => array( <%= mb_scope %> ), // Post type\n" +
        "       'context'      => '<%= mb_context %>',\n" +
        "       'priority'     => '<%= mb_priority %>',\n" +
        "       'show_names'   => true,\n" +
        "       'fields'       => array(\n" +
        "<%= fields %>         \n" + "		)\n" + "	);\n" +
        "	return $meta_boxes;\n" + "}\n";

      var fieldTemplate = _.template( field );
      var mbTemplate = _.template( metabox );

      var fields = "";
      for ( i in elements.elements ) {
        var element = elements.elements[ i ];
        if ( element.has_option && 'array' === element.option_type ) {
          element.option_elems =
            "";
          for ( j in element.options ) {
            var opt_elem_tmplt = _.template( option_arr_elem );

            element.option_elems +=
              opt_elem_tmplt( element.options[ j ] );
          }

          var optionTemplate = _.template( option_arr );
          element.option_param =
            optionTemplate( element );

        } else if ( element.has_option ) {
          var optionTemplate = _.template( option_cb );
          element.option_param =
            optionTemplate( element );
        } else {
          element.option_param =
            "";
        }

        fields +=
          fieldTemplate( element );
      }

      elements.fields =
        fields;
      var code = mbTemplate( elements );
      $( "#code" ).html( "<code class='language-php'>" + code + "</code>" );
      Prism.highlightAll();
      $( "#codecontainer" ).show();
    }

  } );
})( jQuery );
