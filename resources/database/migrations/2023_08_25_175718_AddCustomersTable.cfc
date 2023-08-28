component {
    
    function up( schema, qb ) {
        schema.create( "customers", function( table ) {
            table.increments( "id" );
            table.timestamp( "created_date" ).nullable();
            table.timestamp( "modified_date" ).nullable();
            table.string( "firstname" );
            table.string( "lastname" );
            table.string( "company" );
            table.string( "email" );
        } );
    }

    function down( schema, qb ) {
        schema.drop( "customers" );
    }

}
