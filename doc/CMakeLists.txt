# doc sub module

# add a target to generate API documentation with Doxygen
find_package(Doxygen)
if(DOXYGEN_FOUND)

configure_file(${CMAKE_CURRENT_SOURCE_DIR}/Doxyfile.in ${CMAKE_CURRENT_BINARY_DIR}/Doxyfile @ONLY)

set(doxyfile Doxyfile)

add_hdrs_ide(${doxyfile})

# -- Add the doc target

# add the target with ALL if you want install to include doc
add_custom_command(OUTPUT doc.done
    COMMAND "${DOXYGEN_EXECUTABLE}" "${CMAKE_CURRENT_BINARY_DIR}/${doxyfile}"
    COMMAND ${CMAKE_COMMAND} -E touch doc.done
    WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}
    COMMENT "-- Generating API documentation with Doxygen..." VERBATIM
  )

add_custom_target(doc DEPENDS doc.done)

# html/ <- the trailing slash is important
file(MAKE_DIRECTORY html)
install(DIRECTORY html/ DESTINATION doc/html)

endif(DOXYGEN_FOUND)
