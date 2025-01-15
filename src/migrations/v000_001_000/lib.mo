import MigrationTypes "../types";
import Time "mo:base/Time";
import v0_1_0 "types";
import D "mo:base/Debug";

module {

  public let BTree = v0_1_0.BTree;
  public let Vector = v0_1_0.Vector;
  public let Set = v0_1_0.Set;
  public type EmitableEvent = v0_1_0.EmitableEvent;
  public type PublicationRecord = v0_1_0.PublicationRecord;

  public func upgrade(prevmigration_state: MigrationTypes.State, args: MigrationTypes.Args, caller: Principal): MigrationTypes.State {

    /*
    todo: implement init args
    let (previousEventIDs,
      pendingEvents) = switch (args) {
      case (?args) {
        switch(args.restore){
          case(?restore){
            let existingPrevIds = BTree.
            (restore.)
          }
        }
      };
      case (_) {("nobody")};
    };
    */

    let state : v0_1_0.State = {
      broadcasters = BTree.init<Text, Set.Set<Principal>>(null);
      previousEventIDs = BTree.init<Text, (Nat, Nat)>(null); //IDUsed, BroadcasterUsed
      pendingEvents = Vector.new<EmitableEvent>();

      var drainEventId = null;
      var eventsProcessing = false;
      var error = null;
      publications = BTree.init<Nat, PublicationRecord>(null);
      publicationsByNamespace = BTree.init<Text, Nat>(null);
      var readyForPublications = false;
    };

    return #v0_1_0(#data(state));
  };
};