import pdfplumber
import xml.etree.ElementTree as ET
from xml.dom import minidom


def extract_toc_to_xml(pdf_path):
    """
    Extracts the table of contents (bookmarks) from a PDF and returns it as an XML string.

    Args:
        pdf_path (str): The path to the PDF file.

    Returns:
        str: A string containing the XML representation of the table of contents,
             or None if no outline/TOC is found or an error occurs.
    """
    try:
        with pdfplumber.open(pdf_path) as pdf:
            # pdf.outline is a list of tuples:
            # (level, title, page_number, destination_details)
            # For older versions of pdfplumber, it might be pdf.doc.catalog['Outlines']
            # or you might need to access pdf.doc.get_outline()
            # We'll try pdf.outline first as it's common in recent versions.

            outline = []
            if hasattr(pdf, "outline") and pdf.outline:
                outline = pdf.outline
            elif hasattr(pdf, "doc") and hasattr(
                pdf.doc, "get_outline"
            ):  # For pdfminer.six backend
                raw_outline_data = pdf.doc.get_outline()
                if raw_outline_data:
                    # Create a mapping from page_objid to page_number for quick lookup
                    # pdf.pages are pdfplumber.Page objects. p.page_number, p.page_objid
                    page_objid_to_number = {
                        p.page_objid: p.page_number
                        for p in pdf.pages
                        if hasattr(p, "page_objid") and hasattr(p, "page_number")
                    }

                    for r_level, r_title, r_dest, r_action, r_se in raw_outline_data:
                        # r_dest can be a list [page_ref, type, ...] or a named destination (bytes)
                        # page_ref is typically a PDFObjRef in pdfminer.six
                        page_num_resolved = None

                        if isinstance(r_dest, list) and len(r_dest) > 0:
                            page_ref = r_dest[0]
                            if hasattr(
                                page_ref, "objid"
                            ):  # Check if it's a PDFObjRef-like object
                                target_objid = page_ref.objid
                                if target_objid in page_objid_to_number:
                                    page_num_resolved = page_objid_to_number[
                                        target_objid
                                    ]
                            # else: r_dest[0] might be something else, or resolution failed.
                        # If r_dest is a named destination (bytes), resolving it is more complex
                        # and typically involves looking up in doc.catalog['Dests'].
                        # This implementation focuses on explicit destinations from PDFObjRefs.

                        if page_num_resolved is not None:
                            # Append (level, title, resolved_page_number, original_destination_details)
                            outline.append(
                                (r_level, r_title, page_num_resolved, r_dest)
                            )
                        else:
                            # Pass the original r_dest for the next stage of processing, or as a fallback.
                            # The next stage will attempt its own resolution or convert to string.
                            # Append (level, title, unresolvable_destination, original_destination_details)
                            outline.append((r_level, r_title, r_dest, r_dest))
                # If raw_outline_data was empty or not processed, outline remains empty here.

            if not outline:
                print(f"No outline (table of contents) found in {pdf_path}")
                # As a fallback, one could try to infer TOC from text properties (font size, position)
                # but that is significantly more complex and error-prone.
                return None

            root = ET.Element("toc")

            # Keep track of current parent for each level
            # This basic approach assumes a flat list from pdf.outline and uses 'level' attribute.
            # For a truly nested XML based on outline levels, a stack-based approach would be better
            # to handle parent-child relationships in the XML structure.
            # However, pdf.outline already provides a flat list with level indicators.

            for item_level, title, page_num_or_dest, *_ in outline:
                # In pdfplumber 0.6.0+, the third item is page_number
                # In some cases or older versions, it might be a destination object/tuple
                # We'll try to get page number directly or from destination if possible
                page_number = page_num_or_dest

                if not isinstance(page_number, int) and hasattr(pdf, "pages"):
                    # Attempt to resolve destination to page number if it's not already an int
                    # This is a simplified approach. Real destination resolution can be complex.
                    # For now, we'll just use the raw destination if it's not an int.
                    # A more robust solution would involve inspecting the destination details.
                    try:
                        # Example: if page_num_or_dest is like {'page_number': X, ...}
                        if (
                            isinstance(page_num_or_dest, dict)
                            and "page_number" in page_num_or_dest
                        ):
                            page_number = page_num_or_dest["page_number"]
                        # Or if it's a direct reference to a page object
                        elif hasattr(page_num_or_dest, "page_number"):
                            page_number = page_num_or_dest.page_number
                        else:  # Fallback to string representation if not easily parsable
                            page_number = str(page_num_or_dest)
                    except Exception:
                        page_number = str(page_num_or_dest)

                entry = ET.SubElement(root, "entry")
                entry.set("level", str(item_level))
                entry.set("title", str(title))
                entry.set(
                    "page", str(page_number)
                )  # page_number might be an int or a string representation of destination

            # Pretty print XML
            xml_str = ET.tostring(root, encoding="unicode")
            dom = minidom.parseString(xml_str)
            return dom.toprettyxml(indent="  ")

    except Exception as e:
        print(f"An error occurred: {e}")
        return None


if __name__ == "__main__":
    # Replace with the actual path to your PDF file
    pdf_file_path = "/Users/andy/bop-modeling-data-2025/bop_modeling_data/Billing Data Model 2-4-1.pdf"

    xml_output = extract_toc_to_xml(pdf_file_path)

    if xml_output:
        print("\nGenerated XML:")
        print(xml_output)

        # Optionally, save to a file
        output_xml_file = "toc.xml"
        with open(output_xml_file, "w", encoding="utf-8") as f:
            f.write(xml_output)
        print(f"\nXML saved to {output_xml_file}")
