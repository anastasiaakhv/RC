workspace "Room Control" "This workspace documents the architecture of the Room Control system for a fictional hospital for the course Architecture of Software Engineering in winter 2022." {

    model {
        patient = person "Patient" "An user that has a room assigned and can control some of the room's equipments."
        nurse = person "Nurse" "A user that has assigned patients, can choose rooms and can control some of the room's equipments."
        login = softwareSystem "Log in" "The aim of this module is to check user credentials and allow them to log into system."
		edb = softwareSystem "Equipment database" "The database that contains all the equipment of the hospital."
       
        roomControl = softwareSystem "Room Control" "The aim of the Room Control module is to manage the rooms in the hospital. The system serves to modernize the hospital" {
           database = container "Database" "contains data about rooms, mapping between equipement->rooms, rooms->patients"
           server = container "Hospital Server" "Handles business functionality and translates it via API" 
            ui = container "User interface" "The interface presented to users. It is a web application or a mobile application or a remote controller."{
              patient -> this "Uses" 
              nurse -> this "Uses"
              login -> this "verifies and sends back identification token to UI"
              this -> login "sends credentials to login"
            }

            
            api = container "API" "The API provides access to the rooms network. It does not need to be configured for any specific UI so any type of it can use the same API"
            group "Business logic" {
    			controller = container "Controller" "The part of the business logic, which processes requests from the API. It decides which modules to call and then return the results to the API."
                notification = container "Notification" "Sends notifications from one instance of the application to another. It is used to notify the nurse whenever a patient uses the call nurse function."
                uei = container "Unified equipment interface" "An interface that provides a singular, unified way to communicate with each piece of equipment, regardless of their manufacturer." {
                    beds = component "Bed control" "Methods that allow interactions with beds."{
                        controller -> this "Sends requests"
                    }
                    lights = component "Lights control" "Methods that allow interactions with lights."{
                        controller -> this "Sends requests"
                    }
                    windows = component "Windows control" "Methods that allow interactions with windows."{
                        controller -> this "Sends requests"
                    }
                    airCond = component "Air conditioning" "Methods that allow interactions with the air conditioner."{
                        controller -> this "Sends requests"
                    }
                }
                rooms = container "Rooms" "Contains all the information about each room (patients and staff assigned to the room, equipment inside the room, ...)"
            }
			DBcommunication = container "Database communication" "Translates business logic's calls into queries of the database needed."
        }
        uiToServer =  ui -> server "translates the request to business logic by API"
        serverToDb =  server -> database "requests data from the database"
        deploymentEnvironment "Server Development"   {
            deploymentNode "Mobile Device" "" "Android or ios" {
                containerInstance ui
                    
            }
            deploymentNode "C#" "" "core"   {
                containerInstance server
            }
                     
            deploymentNode "Apache CouchDB" "" "Apache CouchDB 3.*"   {
                containerInstance database
             }
        }
      
       
       
        # Relationships
        ui -> api "Sends users' requests"
        api -> controller "Forwards parameters of users' requests"
        controller -> rooms "Verifies and requests the room that the user is located in"
        rooms -> controller "Provides information about each room: people assigned to the room and available equipment in the room"
        uei -> controller "Returns responses from the equipment"
        uei -> DBcommunication "Forwards requests and parameters to the actual equipment and tell them to do things"
        controller -> notification "Requests the sending of notification to an user"
        roomsToApi = rooms -> api "Returns result from rooms"
        apiToUi = api -> ui "Returns result from api"
        DBcommunication -> database "retreives data"       
 
        
    }
    
     views {
        deployment roomControl "Server Development" {
            include *
             autolayout lr
            
        } 
        systemContext roomControl {
            include *
             autolayout lr
        }
       
        container roomControl {
            include *
              
           exclude server
           
            exclude uiToServer
            exclude serverToDb
            exclude apiToUi
            exclude roomsToApi
             autolayout lr
        }
        component uei {
            include *
             autolayout lr
          
        }
        
        
        
        dynamic uei "window" {
            patient -> ui
            ui -> api
            api -> controller
            controller -> rooms
            rooms -> controller
            controller -> windows
            windows -> controller
            controller -> api
            api -> ui
             
          
            
        }
        dynamic uei "lights"{
            patient -> ui
            ui -> api
            api -> controller
            controller -> rooms
            rooms -> controller
            controller -> lights
            lights -> controller
            controller -> api
            api -> ui
          
            
        }
        dynamic uei "beds" {
            patient -> ui
            ui -> api
            api -> controller
            controller -> rooms
            rooms -> controller
            controller -> beds
            beds -> controller
            controller -> api
            api -> ui
            
        }
        dynamic uei "airConditioner"{
            patient -> ui
            ui -> api
            api -> controller
            controller -> rooms
            rooms -> controller
            controller -> airCond
            airCond -> controller
            controller -> api
            api -> ui
         }
         
         dynamic roomControl "chooseRoom"{
            nurse -> ui
            ui -> api
            api -> controller
            controller -> rooms
            rooms -> controller
            controller -> api
            api -> ui
         }

        
        theme default
    }

}
