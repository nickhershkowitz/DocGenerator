/*
	Copyright (C) 2008 Nicolas Roard

	Author:  Nicolas Roard
	Author:  Quentin Mathe <quentin.mathe@gmail.com>
	Date:  June 2008
	License:  Modified BSD (see COPYING)
 */

#import "DocFunction.h"
#import "DocHTMLElement.h"
#import "DocDescriptionParser.h"
#import "DocIndex.h"
#import "DocParameter.h"

@implementation DocFunction

// TODO: We could use better span class names perhaps rather than just reusing 
// the DocMethod ones... not sure though.
- (DocHTMLElement *) HTMLRepresentation
{
	H hReturn = [[self returnParameter] HTMLRepresentationWithParentheses: NO];
	H hSignature = [SPAN class: @"methodSignature" 
	                      with: hReturn
	                       and: [SPAN class: @"selector" with: @" " and: [self name]]
	                       and: @"("];

	BOOL isFirst = YES;
	for (DocParameter *param in [self parameters])
	{
		H hParam = [param HTMLRepresentationWithParentheses: NO];

		if (NO == isFirst)
		{
			[hSignature and: @", "];
		}
		[hSignature and: hParam];

		isFirst = NO;
	}

	[hSignature with: @")"];

	H hFunctionDesc = [DIV class: @"methodDescription" 
	                        with: [self HTMLDescriptionWithDocIndex: [DocIndex currentIndex]]
	                         and: [self HTMLAddendumRepresentation]];
	H hFunctionBlock = [DIV class: @"method" with: [DL class: @"collapsable" with: [DT with: hSignature]
	                                                                          and: [DD with: hFunctionDesc]]];

	//NSLog(@"Function %@", hFunctionBlock);
	return hFunctionBlock;
}

- (NSString *) GSDocElementName
{
	return @"function";
}

- (SEL) weaveSelector
{
	return @selector(weaveFunction:);
}

- (void) parser: (GSDocParser *)parser 
   startElement: (NSString *)elementName
 withAttributes: (NSDictionary *)attributeDict
{
	if ([elementName isEqualToString: [self GSDocElementName]]) /* Opening tag */
	{
		BEGINLOG();
		[self setReturnType: [attributeDict objectForKey: @"type"]];
		[self setName: [attributeDict objectForKey: @"name"]];
	}
}

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"

- (void) parser: (GSDocParser *)parser
     endElement: (NSString *)elementName
    withContent: (NSString *)trimmed
{
	if ([elementName isEqualToString: @"arg"]) 
	{
		NSString *type = [parser argTypeFromArgsAttributes: [parser currentAttributes]];
		[self addParameter: [DocParameter parameterWithName: trimmed type: type]];	
	}
	else if ([elementName isEqualToString: @"desc"]) 
	{
		[self appendToRawDescription: trimmed];
		CONTENTLOG();
	}
	else if ([elementName isEqualToString: [self GSDocElementName]]) /* Closing tag */
	{
		DocDescriptionParser* descParser = [DocDescriptionParser new];

		[descParser parse: [self rawDescription]];
		
		//NSLog(@"Function raw description <%@>", [self rawDescription]);
		
		[self addInformationFrom: descParser];
		
		[(id)[parser weaver] performSelector: [self weaveSelector] withObject: self];
		
		ENDLOG2(name, [self task]);
	}
}

- (void) parseProgramComponent: (SCKFunction *)aFunction
{	
	[self setName: [aFunction name]];
	[self appendToRawDescription: [[aFunction documentation] string]];
	
	DocDescriptionParser *descriptionParser = [DocDescriptionParser new];
	
	[descriptionParser parse: [self rawDescription]];
	[self addInformationFrom: descriptionParser];
}

#pragma clang diagnostic pop

@end
