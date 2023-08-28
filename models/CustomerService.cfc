component {

    property name="wirebox" inject="wirebox";

    /**
     * Delete a customer.
     */
    function deleteByIds( array ids ) {
        wirebox.getInstance('QueryBuilder@qb')
            .from( "customers" )
            .whereIn( "id", ids )
            .delete();
    }

    /**
     * Get by ids.
     */
    function getByIDs( array ids ) {
        return wirebox.getInstance('QueryBuilder@qb')
                        .from( "customers" )
                        .whereIn( "id", ids )
                        .get();
    }

    /**
     * Get with filters
     */
    function search( filters = {} ) {
        if ( structKeyExists( variables, "_currentCustomers" ) ) {
            return variables._currentCustomers;
        }
        variables._currentCustomers = wirebox.getInstance('QueryBuilder@qb')
                    .from( "customers")
                    .when( len( filters.searchTerm ), function( q ) {
                        q.where( "id", "=", filters.searchTerm )
                            .orWhere( "firstname", "like", "%#trim( filters.searchTerm )#%" )
                            .orWhere( "lastname", "like", "%#trim( filters.searchTerm )#%" )
                            .orWhere( "company", "like", "%#trim( filters.searchTerm )#%" )
                            .orWhere( "email", "like", "%#trim( filters.searchTerm )#%" );
                    } )
                    .limit( filters.limit )
                    .orderBy( filters.sortBy & " " & filters.sortDirection )
                    .paginate( filters.page, filters.limit );

        return variables._currentCustomers;
    }

    /**
     * Seed the database
     */
    function seedDatabase() {
        var mockData = wirebox.getInstance( "MockData@MockDataCFC" );

        var customers = mockData.mock( 
            $num = "300",
            $returnType = "array",
            firstname = "fname",
            lastname = "lname",
            email = "email"
        );

        customers.each( function( customer ) {
            wirebox.getInstance('QueryBuilder@qb').newQuery().from( "customers" )
                .insert( {
                    "id" = createUUID(),
                    "firstname" = customer.firstname,
                    "lastname" = customer.lastname,
                    "company" = "#customer.lastname# LLC",
                    "email" = customer.email,
                    "created_date": now(),
                    "modified_date": now()
                } );

        } );
    }

}