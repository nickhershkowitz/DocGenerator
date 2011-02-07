#import <Foundation/Foundation.h>
#include <graphviz/gvc.h>

@interface GraphWriter : NSObject
{
	NSMutableDictionary* mNodes;
	NSMutableArray* mEdges;
	Agraph_t *mGraph;
	GVC_t* mGraphContext;
}
- (void) cleanupGraph;
- (NSValue*) addNode: (NSString*) node;
- (void) addEdge: (NSString*) nodeA to: (NSString*) nodeB;
- (void) setAttribute: (NSString*) attribute
		 with: (NSString*) value
		   on: (NSString*) node;
- (void) layout;
- (void) generateFile: (NSString*) path withFormat: (NSString*) format;
@end