component {

    function run( qb, mockdata ) {
        var customers = mockData.mock( 
            $num = "300",
            $returnType = "array",
            firstname = "fname",
            lastname = "lname",
            email = "email"
        );

        customers.each( function( customer ) {
            qb.newQuery().from( "customers" )
                .insert( {
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
