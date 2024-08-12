import Time "mo:base/Time";
import Principal "mo:base/Principal";
import Star "mo:star/star";
import VectorLib "mo:vector";
import BTreeLib "mo:stableheapbtreemap/BTree";
import SetLib "mo:map/Set";
import MapLib "mo:map/Map";
import TT "../../../../timerTool/src";
import ICRC72Subscriber "../../../../icrc72-subscriber.mo/src";
// please do not import any types from your project outside migrations folder here
// it can lead to bugs when you change those types later, because migration types should not be changed
// you should also avoid importing these types anywhere in your project directly from here
// use MigrationTypes.Current property instead


module {

  public let BTree = BTreeLib;
  public let Set = SetLib;
  public let Map = MapLib;
  public let Vector = VectorLib;

  public type Namespace = Text;

  public type ICRC16Property = {
    name : Text;
    value : ICRC16;
    immutable : Bool;
  };

  public type ICRC16 = {
    #Array : [ICRC16];
    #Blob : Blob;
    #Bool : Bool;
    #Bytes : [Nat8];
    #Class : [ICRC16Property];
    #Float : Float;
    #Floats : [Float];
    #Int : Int;
    #Int16 : Int16;
    #Int32 : Int32;
    #Int64 : Int64;
    #Int8 : Int8;
    #Map : [(Text, ICRC16)];
    #ValueMap : [(ICRC16, ICRC16)];
    #Nat : Nat;
    #Nat16 : Nat16;
    #Nat32 : Nat32;
    #Nat64 : Nat64;
    #Nat8 : Nat8;
    #Nats : [Nat];
    #Option : ?ICRC16;
    #Principal : Principal;
    #Set : [ICRC16];
    #Text : Text;
  };

  //ICRC3 Value
  public type Value = {
    #Nat : Nat;
    #Int : Int;
    #Text : Text;
    #Blob : Blob;
    #Array : [Value];
    #Map : [(Text, Value)];
  };

  public type ICRC16Map = [(Text, ICRC16)];

  public type NewEvent = {
    namespace : Text;
    data : ICRC16;
    headers : ?ICRC16Map;
  };

  public type EmitableEvent = {
    broadcaster: Principal;
    id : Nat;
    prevId : ?Nat;
    timestamp : Nat;
    namespace : Text;
    source : Principal;
    data : ICRC16;
    headers : ?ICRC16Map;
  };



  public type Event = {
    id : Nat;
    prevId : ?Nat;
    timestamp : Nat;
    namespace : Text;
    source : Principal;
    data : ICRC16;
    headers : ?ICRC16Map;
  };

  public type EventNotification = {
      id : Nat;
      eventId : Nat;
      prevEventId : ?Nat;
      timestamp : Nat;
      namespace : Text;
      data : ICRC16;
      source : Principal;
      headers : ?ICRC16Map;
      filter : ?Text;
  };

  public let CONST = {
    publisher = {
      actions = {
        drain = "icrc72:publisher:drain";
      };
      sys = "icrc72:publisher:sys:";
      broadcasters = {
        add = "icrc72:publisher:broadcaster:add";
        remove = "icrc72:publisher:broadcaster:remove";
        error = "icrc72:publisher:broadcaster:error";
      };
    };
    broadcasters = {
      publisher={
        broadcasters = {
          add = "icrc72:broadcaster:publisher:broadcaster:add";
          remove = "icrc72:broadcaster:publisher:broadcaster:remove";
        };
      }
    }
  };

  public type PublicationRegistration = {
    namespace : Text; // The namespace of the publication for categorization and filtering
    config : ICRC16Map; // Additional configuration or metadata about the publication
    memo: ?Blob;
    // publishers : ?[Principal]; // Optional list of publishers authorized to publish under this namespace
    // subscribers : ?[Principal]; // Optional list of subscribers authorized to subscribe to this namespace
    // mode : Nat; // Publication mode (e.g., sequential, ranked, etc.)
  };

  public type NewPublicationRegistration = {
    namespace : Text; // The namespace of the publication for categorization and filtering
    config : ICRC16Map; // Additional configuration or metadata about the publication
    memo: ?Blob;

    // publishers : ?[Principal]; // Optional list of publishers authorized to publish under this namespace
    // subscribers : ?[Principal]; // Optional list of subscribers authorized to subscribe to this namespace
    // mode : Nat; // Publication mode (e.g., sequential, ranked, etc.)
  };

  public type SubscriptionRegistration = {
    namespace : Text; // The namespace of the publication for categorization and filtering
    config : ICRC16Map; // Additional configuration or metadata about the publication
    memo: ?Blob;
  };


  public type SubscriberInterface = {
    handleNotification : ([Nat]) -> async ();
    registerSubscription : (SubscriptionRegistration) -> async Nat;
  };

  public type InitArgs ={
    restore : ?{
      previousEventIDs : [(Text, (Nat, Nat))]; //IDUsed, BroadcasterUsed
      pendingEvents: [EmitableEvent];
    };
  };

  public type Environment = {
    addRecord: ?(([(Text, Value)], ?[(Text,Value)]) -> Nat);
    generateId: ?((Text, State) -> Nat);
    icrc72Subscriber : ICRC72Subscriber.Subscriber;
    icrc72OrchestratorCanister : Principal;
    tt: TT.TimerTool;
  };

  public type PublicationRecord = {
    namespace : Text;
    id: Nat;
  };

  ///MARK: State
  public type State = {
    broadcasters : BTree.BTree<Text, Vector.Vector<Principal>>;
    publications : BTree.BTree<Nat, PublicationRecord>;
    publicationsByNamespace : BTree.BTree<Text, Nat>; 
    previousEventIDs : BTree.BTree<Text, (Nat, Nat)>; //Namespace, Publication, IDUsed
    pendingEvents: Vector.Vector<EmitableEvent>;
    var drainEventId : ?TT.ActionId;
    var eventsProcessing : Bool;
    var readyForPublications: Bool;
    var error: ?Text;
  };
};