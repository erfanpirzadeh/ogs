# Source files
SET( SOURCES
	mainwindow.cpp
)

# Moc Header files
SET( MOC_HEADERS
	mainwindow.h
)

# Header files
SET( HEADERS

)

# UI files
SET( UIS
	mainwindow.ui
)


# Run Qts user interface compiler uic on .ui files
QT4_WRAP_UI( UI_HEADERS ${UIS} )

QT4_ADD_RESOURCES( QTRESOURCES ./Img/icons.qrc )

# Run Qts meta object compiler moc on header files
QT4_WRAP_CPP( MOC_SOURCES ${MOC_HEADERS} )

# Include the headers which are generated by uic and moc
# and include additional header
INCLUDE_DIRECTORIES(
	${CMAKE_CURRENT_BINARY_DIR}/../BaseLib
	${CMAKE_CURRENT_SOURCE_DIR}/../BaseLib
	${CMAKE_CURRENT_SOURCE_DIR}/../MathLib
	${CMAKE_CURRENT_SOURCE_DIR}/../GeoLib
	${CMAKE_CURRENT_SOURCE_DIR}/../FileIO
	${CMAKE_CURRENT_SOURCE_DIR}/../MeshLib
	${CMAKE_CURRENT_SOURCE_DIR}/../MeshLibGEOTOOLS
	${CMAKE_CURRENT_SOURCE_DIR}/../OGS
	${CMAKE_CURRENT_BINARY_DIR}
	${CMAKE_CURRENT_BINARY_DIR}/Base
	${CMAKE_CURRENT_BINARY_DIR}/DataView
	${CMAKE_CURRENT_BINARY_DIR}/DataView/StratView
	${CMAKE_CURRENT_BINARY_DIR}/DataView/DiagramView
	${CMAKE_CURRENT_BINARY_DIR}/VtkVis
	${CMAKE_CURRENT_BINARY_DIR}/VtkAct
	${CMAKE_CURRENT_SOURCE_DIR}/Base
	${CMAKE_CURRENT_SOURCE_DIR}/DataView
	${CMAKE_CURRENT_SOURCE_DIR}/DataView/StratView
	${CMAKE_CURRENT_SOURCE_DIR}/DataView/DiagramView
	${CMAKE_CURRENT_SOURCE_DIR}/VtkVis
	${CMAKE_CURRENT_SOURCE_DIR}/VtkAct
)

# Put moc files in a project folder
SOURCE_GROUP("UI Files" REGULAR_EXPRESSION "\\w*\\.ui")
SOURCE_GROUP("Moc Files" REGULAR_EXPRESSION "moc_.*")

# Create the library
ADD_EXECUTABLE( ogs-gui MACOSX_BUNDLE
	main.cpp
	${SOURCES}
	${HEADERS}
	${MOC_HEADERS}
	${MOC_SOURCES}
	${UIS}
	${QTRESOURCES}
)

TARGET_LINK_LIBRARIES( ogs-gui
	${QT_LIBRARIES}
	BaseLib
	GeoLib
	FileIO
	MeshLib
	#MSHGEOTOOLS
	OgsLib
	QtBase
	QtDataView
	StratView
	VtkVis
	VtkAct
	${Boost_LIBRARIES}
	${VTK_LIBRARIES}
	zlib
	shp
)

IF(VTK_NETCDF_FOUND)
	TARGET_LINK_LIBRARIES( ogs-gui vtkNetCDF vtkNetCDF_cxx )
ELSE()
	TARGET_LINK_LIBRARIES( ogs-gui ${Shapelib_LIBRARIES} )
ENDIF () # Shapelib_FOUND

IF (GEOTIFF_FOUND)
	TARGET_LINK_LIBRARIES( ogs-gui ${GEOTIFF_LIBRARIES} )
ENDIF () # GEOTIFF_FOUND

ADD_DEPENDENCIES ( ogs-gui VtkVis OGSProject )

IF(MSVC)
	# Set linker flags
	SET(CMAKE_EXE_LINKER_FLAGS_DEBUG "${CMAKE_EXE_LINKER_FLAGS_DEBUG} /NODEFAULTLIB:MSVCRT /IGNORE:4099")
	TARGET_LINK_LIBRARIES( ogs-gui winmm)
ENDIF(MSVC)

IF(OGS_BUILD_INFO)
	ADD_DEFINITIONS(-DOGS_BUILD_INFO)
ENDIF() # OGS_BUILD_INFO

### OpenSG support ###
IF (VTKOSGCONVERTER_FOUND)
	USE_OPENSG(ogs-gui)
	INCLUDE_DIRECTORIES( ${VTKOSGCONVERTER_INCLUDE_DIRS} )
	TARGET_LINK_LIBRARIES( ogs-gui ${VTKOSGCONVERTER_LIBRARIES} )
ENDIF ()

IF(VTKFBXCONVERTER_FOUND)
	TARGET_LINK_LIBRARIES(ogs-gui ${VTKFBXCONVERTER_LIBRARIES})
ENDIF()

IF(OGS_USE_VRPN)
	INCLUDE_DIRECTORIES( ${CMAKE_CURRENT_SOURCE_DIR}/Vrpn ${CMAKE_CURRENT_BINARY_DIR}/Vrpn )
	TARGET_LINK_LIBRARIES( ogs-gui ${VRPN_LIBRARIES} OgsVrpn )
ENDIF()

set_property(TARGET ogs-gui PROPERTY FOLDER "DataExplorer")


####################
### Installation ###
####################

IF(APPLE)
	SET(MACOSX_BUNDLE_INFO_STRING "${PROJECT_NAME} ${OGS_VERSION}")
	SET(MACOSX_BUNDLE_BUNDLE_VERSION "${PROJECT_NAME} ${OGS_VERSION}")
	SET(MACOSX_BUNDLE_LONG_VERSION_STRING "${PROJECT_NAME} ${OGS_VERSION}")
	SET(MACOSX_BUNDLE_SHORT_VERSION_STRING "${OGS_VERSION}")
	SET(MACOSX_BUNDLE_COPYRIGHT "2013 OpenGeoSys Community")
	#SET(MACOSX_BUNDLE_ICON_FILE "audio-input-microphone.icns")
	SET(MACOSX_BUNDLE_GUI_IDENTIFIER "org.opengeosys")
	SET(MACOSX_BUNDLE_BUNDLE_NAME "${PROJECT_NAME}")

	SET(MACOSX_BUNDLE_RESOURCES "${EXECUTABLE_OUTPUT_PATH}/ogs-gui.app/Contents/Resources")
	SET(MACOSX_BUNDLE_ICON "${ICONS_DIR}/${MACOSX_BUNDLE_ICON_FILE}")
	#EXECUTE_PROCESS(COMMAND ${CMAKE_COMMAND} -E make_directory ${MACOSX_BUNDLE_RESOURCES})
	#EXECUTE_PROCESS(COMMAND ${CMAKE_COMMAND} -E copy_if_different ${MACOSX_BUNDLE_ICON} ${MACOSX_BUNDLE_RESOURCES})

	INSTALL (TARGETS ogs-gui DESTINATION .)
	SET(CMAKE_INSTALL_SYSTEM_RUNTIME_DESTINATION .)
	INCLUDE(InstallRequiredSystemLibraries)
	INCLUDE(DeployQt4)
	INSTALL_QT4_EXECUTABLE(ogs-gui.app)

	RETURN()
ENDIF()

INSTALL (TARGETS ogs-gui RUNTIME DESTINATION bin COMPONENT ogs_gui)

IF(MSVC)
	SET(OGS_GUI_EXE ${EXECUTABLE_OUTPUT_PATH}/Release/ogs-gui.exe)
ELSE(MSVC)
	SET(OGS_GUI_EXE ${EXECUTABLE_OUTPUT_PATH}/ogs-gui)
ENDIF(MSVC)

INCLUDE(GetPrerequisites)
IF(EXISTS ${OGS_GUI_EXE})
	IF(MSVC)
		GET_PREREQUISITES(${OGS_GUI_EXE} OGS_GUI_DEPENDENCIES 1 1 "" "")
	ELSE()
		GET_PREREQUISITES(${OGS_GUI_EXE} OGS_GUI_DEPENDENCIES 0 1 "/usr/local/lib;/;${VTK_DIR};/usr/lib64;" "")
	ENDIF()
	MESSAGE (STATUS "ogs-gui depends on:")
	FOREACH(DEPENDENCY ${OGS_GUI_DEPENDENCIES})
		IF(NOT ${DEPENDENCY} STREQUAL "not") # Some bug on Linux?
			GP_RESOLVE_ITEM ("/" "${DEPENDENCY}" ${OGS_GUI_EXE} "/usr/local/lib;/;${VTK_DIR};/usr/lib64;" DEPENDENCY_PATH)
			GET_FILENAME_COMPONENT(RESOLVED_DEPENDENCY_PATH "${DEPENDENCY_PATH}" REALPATH)
			STRING(TOLOWER ${DEPENDENCY} DEPENDENCY_LOWER)
			IF("${DEPENDENCY_LOWER}" MATCHES "tiff|blas|lapack|proj|jpeg|qt|gfortran|vtk")
				SET(DEPENDENCY_PATHS ${DEPENDENCY_PATHS} ${RESOLVED_DEPENDENCY_PATH} ${DEPENDENCY_PATH})
				MESSAGE("    ${DEPENDENCY}")
			ENDIF()
		ENDIF()
	ENDFOREACH (DEPENDENCY IN ${OGS_GUI_DEPENDENCIES})
	INSTALL (FILES ${DEPENDENCY_PATHS} DESTINATION bin COMPONENT ogs_gui)
	IF(${CMAKE_SYSTEM_NAME} MATCHES "Linux")
		INSTALL(PROGRAMS data-explorer.sh DESTINATION . COMPONENT ogs_gui)
	ENDIF()
	ADD_CUSTOM_COMMAND(TARGET ogs-gui POST_BUILD COMMAND ;) # For caching: excetuting empty command
ELSE()
	# Run CMake after ogs-gui was built to run GetPrerequisites on executable
	ADD_CUSTOM_COMMAND(TARGET ogs-gui POST_BUILD COMMAND ${CMAKE_COMMAND}
		ARGS ${CMAKE_SOURCE_DIR} WORKING_DIRECTORY ${CMAKE_BINARY_DIR} VERBATIM)
ENDIF()
