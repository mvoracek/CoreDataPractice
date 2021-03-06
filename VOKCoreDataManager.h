//
//  VOKCoreDataManager.h
//  VOKCoreData
//

#ifndef __IPHONE_5_0
#warning "VOKCoreDataManager uses features only available in iOS SDK 5.0 and later."
#endif

#ifndef CDLog
#   ifdef DEBUG
#       define CDLog(...) NSLog(@"%s\n%@", __PRETTY_FUNCTION__, [NSString stringWithFormat:__VA_ARGS__])
#   else
#       define CDLog(...) /* */
#   endif
#endif

#ifndef CDSELECTOR
#   ifdef DEBUG
#       define CDSELECTOR(x) NSStringFromSelector(@selector(x))
#   else
#       define CDSELECTOR(x) @#x //in release builds @#x becomes @"{x}"
#   endif
#endif

#define MAP_FOREIGN_TO_LOCAL(x, y) [VOKManagedObjectMap mapWithForeignKeyPath:x coreDataKey:CDSELECTOR(y)]

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

#import "VOKManagedObjectMapper.h"
#import "VOKManagedObject.h"

typedef NS_ENUM (NSInteger, VOKMigrationFailureOption) {
    /// No handling of a failed migration, will likely cause app instability and crashing when a migration fails.
    VOKMigrationFailureOptionNone,
    /// Silently delete and recreate the sqlite database file, data will be erased, but instability and crashing will be avoided
    VOKMigrationFailureOptionWipeRecovery,
    /// Same as VOKMigrationFailureOptionWipeRecoveryAndAlert, but will also notify the user that data has been erased via UIAlertView.
    VOKMigrationFailureOptionWipeRecoveryAndAlert,
};


@interface VOKCoreDataManager : NSObject

/**
 Returns the singleton core data manager. VOKCoreDataManager is not expected to be subclassed.
 On launch you should also set the resource and database names. Example:
 @code
 [[VOKCoreDataManager sharedInstance] setResource:@"VICoreDataModel" database:@"VICoreDataModel.sqlite"];
 @endcode
 @return The shared core data manager.
 */
+ (VOKCoreDataManager *)sharedInstance;

/**
 The primary managed object context. Only for use on the main queue.
 @return 
 The main managed object context.
 */
- (NSManagedObjectContext *)managedObjectContext;

/**
 Set the name of the managed object model and the name of the SQL lite store on disk.
 @param resource
 The filename of the mom or momd file in your project
 @param database
 The filename of the SQLite store in your application. A nil database name will create an in-memory store.
 */
- (void)setResource:(NSString *)resource
           database:(NSString *)database;

/**
 *  In case of a migration failure, these options allow possible recovery and notification
 */
@property VOKMigrationFailureOption migrationFailureOptions;

/**
 Create a new instance of a given NSManagedObject subclass.
 @param managedObjectClass
 The class of the object to return.
 @param contextOrNil
 The managed object context in which to insert the new object. A nil context will use the main context.
 @return 
 A new instance of the requested managed object subclass.
 */
- (NSManagedObject *)managedObjectOfClass:(Class)managedObjectClass
                                inContext:(NSManagedObjectContext *)contextOrNil;
/**
 Set the object mapper for a given NSManagedObject subclass
 @param objMap
 The object mapper for importing data.
 @param objectClass
 Specifies the class to instantiate or fetch when importing data.
 @return
 YES if the mapper and class are set. NO if the relationship could not be set.
 */
- (BOOL)setObjectMapper:(VOKManagedObjectMapper *)objMap
               forClass:(Class)objectClass;
/**
 Deserializes the NSDictionaries full of strings and creates/updates instances in the given context.
 @param inputArray
 An NSArray of NSDictionaries with data to be deserialized and imported into the managed object context.
 @param objectClass
 Specifies the class to instantiate or fetch when importing data.
 @param contextOrNil
 The managed object context in which to insert or fetch instances of the given class. A nil context will use the main context.
 @return
 An NSArray of instances of the given class. As subclasses of NSManagedObject they are not threadsafe.
 */
- (NSArray *)importArray:(NSArray *)inputArray
                forClass:(Class)objectClass
             withContext:(NSManagedObjectContext*)contextOrNil;

/**
 Deserializes a single NSDictionaries full of strings and updates instances the given object.
 @param inputDict
 An NSDictionary with data to be deserialized.
 @param object
 The object to update.
 */
- (void)setInformationFromDictionary:(NSDictionary *)inputDict
                    forManagedObject:(NSManagedObject *)object;

/**
 Serializes a managed object.
 @param object
 Specifies the class to instantiate or fetch when importing data.
 @param keyPathsEnabled
 If enabled the dictionary will include nexted dictionaries, following keys paths. If disabled the resulting dictionary will be flat.
 @return
 An NSDictionary representation of the given object using the mapper associated with the object's class.
 */
- (NSDictionary *)dictionaryRepresentationOfManagedObject:(NSManagedObject *)object respectKeyPaths:(BOOL)keyPathsEnabled;

/**
 Counts every instance of a given class using the main managed object context. Includes subentities.
 NOT threadsafe! Always use a temp context if you are NOT on the main queue.
 @param managedObjectClass
 The class to count.
 @return
 Zero or greater count of the instances of the class.
 */
- (NSUInteger)countForClass:(Class)managedObjectClass;

/**
 Counts every instance of a given class using the given managed object context. Includes subentities.
 NOT threadsafe! Always use a temp context if you are NOT on the main queue.
 @param managedObjectClass
 The class to count.
 @param contextOrNil
 The managed object context in which count instances of the given class. A nil context will use the main context.
 @return
 Zero or greater count of the instances of the class.
 */
- (NSUInteger)countForClass:(Class)managedObjectClass
                 forContext:(NSManagedObjectContext *)contextOrNil;

/**
 Counts every instance of a given class that matches the predicate using the given managed object context. Includes subentities.
 NOT threadsafe! Always use a temp context if you are NOT on the main queue.
 @param managedObjectClass
 The class to count.
 @param predicate
 The predicate limit the count.
 @param contextOrNil
 The managed object context in which count instances of the given class. A nil context will use the main context.
 @return
 Zero or greater count of the instances of the class.
 */
- (NSUInteger)countForClass:(Class)managedObjectClass
              withPredicate:(NSPredicate *)predicate
                 forContext:(NSManagedObjectContext *)contextOrNil;

/**
 Fetches every instance of a given class using the main managed object context. Includes subentities.
 NOT threadsafe! Always use a temp context if you are NOT on the main queue.
 @param managedObjectClass
 The class to fetch
 @return
 An NSArray of managed object subclasses. Not threadsafe.
 */
- (NSArray *)arrayForClass:(Class)managedObjectClass;

/**
 Fetches every instance of a given class using the given managed object context. Includes subentities.
 NOT threadsafe! Always use a temp context if you are NOT on the main queue.
 @param managedObjectClass
 The class to fetch.
 @param contextOrNil
 The managed object context in which fetch instances of the given class. A nil context will use the main context.
 @return
 An NSArray of managed object subclasses. Not threadsafe.
 */
- (NSArray *)arrayForClass:(Class)managedObjectClass
                forContext:(NSManagedObjectContext *)contextOrNil;

/**
 Fetches every instance of a given class that matches the predicate using the given managed object context. Includes subentities.
 NOT threadsafe! Always use a temp context if you are NOT on the main queue.
 @param managedObjectClass
 The class to fetch.
 @param predicate
 The predicate limit the fetch.
 @param contextOrNil
 The managed object context in which fetch instances of the given class. A nil context will use the main context.
 @return
 An NSArray of managed object subclasses. Not threadsafe.
 */
- (NSArray *)arrayForClass:(Class)managedObjectClass
             withPredicate:(NSPredicate *)predicate
                forContext:(NSManagedObjectContext *)contextOrNil;

/**
 Finds an object for a given NSManagedObjectID URI Representation. This method relies on existingObjectWithID:error:.
 A very malformed URI will cause managedObjectIDForURIRepresentation: to throw an exception. All other known errors are handled by logging and returning nil.
 @param uri
 URIRepresetion of an NSManagedObjectId
 @param contextOrNil
 The managed object context in which fetch instances of the given class. A nil context will use the main context.
 @return 
 The object matching the uri passed in. If the object doesn't exist nil is returned.
 */
- (id)existingObjectAtURI:(NSURL *)uri forManagedObjectContext:(NSManagedObjectContext *)contextOrNil;

/**
 Deletes a given object in its current context. Uses the object's context. As always, remember to keep NSManagedObjects on one queue.
 @param object
 The object to delete.
 */
- (void)deleteObject:(NSManagedObject *)object;

/**
 Deletes all instances of a class in the given context.
 @param managedObjectClass
 Instances of this class will all be deleted from the given context.
 @param contextOrNil
 The managed object context in which delete instances of the given class. A nil context will use the main context.
 @return
 YES if all objects were successfully deleted. NO if the attemp to delete was unsuccessful.
 */
- (BOOL)deleteAllObjectsOfClass:(Class)managedObjectClass
                        context:(NSManagedObjectContext *)contextOrNil;

/**
 Saves the main context asynchronously on the main queue. If already on the main queue it will block and save synchronously.
 */
- (void)saveMainContext;

/**
 Saves the main context synchronously on the main queue. If already on the main queue it performs the same as saveMainContext.
 */
- (void)saveMainContextAndWait;

/**
 Provides a managed object context for scratch work or background processing. As with all managed object contexts it is not threadsafe.
 Create the context and do work on the same queue. You are responsible for retaining temporary contexts yourself.
 Here is an example background import:
 @code
 NSManagedObjectContext *backgroundContext = [[VOKCoreDataManager sharedInstance] temporaryContext];
 [self loadDataWithContext:backgroundContext]; //do some data loading
 [[VOKCoreDataManager sharedInstance] saveAndMergeWithMainContext:backgroundContext];
 @endcode
 @return
 A managed object context with the same persistant store coordinator as tha main context, but otherwise no relationship.
 */
- (NSManagedObjectContext *)temporaryContext;

/**
 This provides a way for an application with heavy amounts of Core Data threading and writing to maintain object graph integrety by assuring that only one context is being written to at once.
 @param writeBlock Do not use GCD or thread jumping inside this block. Handle all fetches, creates and writes using the tempContext variable passed to this block. Do not save or merge this context, it will be done for you.
 @param completion This will be fired on the main thread once the context has been saved.
 */
+ (void)writeToTemporaryContext:(void (^)(NSManagedObjectContext *tempContext))writeBlock
                     completion:(void (^)(void))completion;

/**
 Saves any temporary managed object context and merges those changes with the main managed object context in a thread-safe way.
 This method is safe to call from any queue.
 @param context
 The termporary context to save. Do not use this method to save the main context.
 */
- (void)saveAndMergeWithMainContext:(NSManagedObjectContext *)context;

/**
 Deletes the persistent stores and resets the main context and model to nil
 */
- (void)resetCoreData;

@end
