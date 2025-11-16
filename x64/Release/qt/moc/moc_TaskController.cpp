/****************************************************************************
** Meta object code from reading C++ file 'TaskController.h'
**
** Created by: The Qt Meta Object Compiler version 68 (Qt 6.8.3)
**
** WARNING! All changes made in this file will be lost!
*****************************************************************************/

#include "../../../../TaskController.h"
#include <QtCore/qmetatype.h>

#include <QtCore/qtmochelpers.h>

#include <memory>


#include <QtCore/qxptype_traits.h>
#if !defined(Q_MOC_OUTPUT_REVISION)
#error "The header file 'TaskController.h' doesn't include <QObject>."
#elif Q_MOC_OUTPUT_REVISION != 68
#error "This file was generated using the moc from 6.8.3. It"
#error "cannot be used with the include files from this version of Qt."
#error "(The moc has changed too much.)"
#endif

#ifndef Q_CONSTINIT
#define Q_CONSTINIT
#endif

QT_WARNING_PUSH
QT_WARNING_DISABLE_DEPRECATED
QT_WARNING_DISABLE_GCC("-Wuseless-cast")
namespace {
struct qt_meta_tag_ZN14TaskControllerE_t {};
} // unnamed namespace


#ifdef QT_MOC_HAS_STRINGDATA
static constexpr auto qt_meta_stringdata_ZN14TaskControllerE = QtMocHelpers::stringData(
    "TaskController",
    "currentProjectIdChanged",
    "",
    "loadingChanged",
    "tasksChanged",
    "taskCreated",
    "taskId",
    "taskUpdated",
    "taskDeleted",
    "taskAssigned",
    "employeeId",
    "errorOccurred",
    "errorMessage",
    "taskCreationFailed",
    "taskUpdateFailed",
    "taskDeletionFailed",
    "taskAssignmentFailed",
    "loadTasksForProject",
    "projectId",
    "loadTasksForCurrentProject",
    "createTask",
    "taskName",
    "description",
    "idParentTache",
    "assignedToId",
    "estimatedTime",
    "dateDebut",
    "dateFin",
    "etat",
    "updateTask",
    "deleteTask",
    "assignTask",
    "getTaskDetails",
    "QVariantMap",
    "getSubTasks",
    "QVariantList",
    "createSubTask",
    "parentTaskId",
    "subTaskName",
    "subTaskDate",
    "deleteSubTask",
    "getTaskHierarchy",
    "getAvailableEmployees",
    "getDepartmentEmployees",
    "getTasksForProject",
    "getCurrentUser",
    "User*",
    "getTasksForProjectByStatus",
    "status",
    "currentProjectId",
    "loading",
    "tasks"
);
#else  // !QT_MOC_HAS_STRINGDATA
#error "qtmochelpers.h not found or too old."
#endif // !QT_MOC_HAS_STRINGDATA

Q_CONSTINIT static const uint qt_meta_data_ZN14TaskControllerE[] = {

 // content:
      12,       // revision
       0,       // classname
       0,    0, // classinfo
      28,   14, // methods
       3,  298, // properties
       0,    0, // enums/sets
       0,    0, // constructors
       0,       // flags
      12,       // signalCount

 // signals: name, argc, parameters, tag, flags, initial metatype offsets
       1,    0,  182,    2, 0x06,    4 /* Public */,
       3,    0,  183,    2, 0x06,    5 /* Public */,
       4,    0,  184,    2, 0x06,    6 /* Public */,
       5,    1,  185,    2, 0x06,    7 /* Public */,
       7,    1,  188,    2, 0x06,    9 /* Public */,
       8,    1,  191,    2, 0x06,   11 /* Public */,
       9,    2,  194,    2, 0x06,   13 /* Public */,
      11,    1,  199,    2, 0x06,   16 /* Public */,
      13,    1,  202,    2, 0x06,   18 /* Public */,
      14,    1,  205,    2, 0x06,   20 /* Public */,
      15,    1,  208,    2, 0x06,   22 /* Public */,
      16,    1,  211,    2, 0x06,   24 /* Public */,

 // slots: name, argc, parameters, tag, flags, initial metatype offsets
      17,    1,  214,    2, 0x0a,   26 /* Public */,
      19,    0,  217,    2, 0x0a,   28 /* Public */,
      20,    9,  218,    2, 0x0a,   29 /* Public */,
      29,    8,  237,    2, 0x0a,   39 /* Public */,
      30,    1,  254,    2, 0x0a,   48 /* Public */,
      31,    2,  257,    2, 0x0a,   50 /* Public */,
      32,    1,  262,    2, 0x0a,   53 /* Public */,
      34,    1,  265,    2, 0x0a,   55 /* Public */,
      36,    6,  268,    2, 0x0a,   57 /* Public */,
      40,    1,  281,    2, 0x0a,   64 /* Public */,
      41,    1,  284,    2, 0x0a,   66 /* Public */,
      42,    0,  287,    2, 0x0a,   68 /* Public */,
      43,    0,  288,    2, 0x0a,   69 /* Public */,
      44,    1,  289,    2, 0x0a,   70 /* Public */,

 // methods: name, argc, parameters, tag, flags, initial metatype offsets
      45,    0,  292,    2, 0x102,   72 /* Public | MethodIsConst  */,
      47,    2,  293,    2, 0x02,   73 /* Public */,

 // signals: parameters
    QMetaType::Void,
    QMetaType::Void,
    QMetaType::Void,
    QMetaType::Void, QMetaType::Int,    6,
    QMetaType::Void, QMetaType::Int,    6,
    QMetaType::Void, QMetaType::Int,    6,
    QMetaType::Void, QMetaType::Int, QMetaType::Int,    6,   10,
    QMetaType::Void, QMetaType::QString,   12,
    QMetaType::Void, QMetaType::QString,   12,
    QMetaType::Void, QMetaType::QString,   12,
    QMetaType::Void, QMetaType::QString,   12,
    QMetaType::Void, QMetaType::QString,   12,

 // slots: parameters
    QMetaType::Void, QMetaType::Int,   18,
    QMetaType::Void,
    QMetaType::Bool, QMetaType::Int, QMetaType::QString, QMetaType::QString, QMetaType::Int, QMetaType::Int, QMetaType::Int, QMetaType::QString, QMetaType::QString, QMetaType::QString,   18,   21,   22,   23,   24,   25,   26,   27,   28,
    QMetaType::Bool, QMetaType::Int, QMetaType::QString, QMetaType::QString, QMetaType::Int, QMetaType::QString, QMetaType::QString, QMetaType::QString, QMetaType::QString,    6,   21,   22,   24,   25,   26,   27,   28,
    QMetaType::Bool, QMetaType::Int,    6,
    QMetaType::Bool, QMetaType::Int, QMetaType::Int,    6,   10,
    0x80000000 | 33, QMetaType::Int,    6,
    0x80000000 | 35, QMetaType::Int,    6,
    QMetaType::Bool, QMetaType::Int, QMetaType::QString, QMetaType::QString, QMetaType::Int, QMetaType::QString, QMetaType::QString,   37,   38,   22,   24,   25,   39,
    QMetaType::Bool, QMetaType::Int,    6,
    0x80000000 | 33, QMetaType::Int,    6,
    0x80000000 | 35,
    0x80000000 | 35,
    0x80000000 | 35, QMetaType::Int,   18,

 // methods: parameters
    0x80000000 | 46,
    0x80000000 | 35, QMetaType::Int, QMetaType::QString,   18,   48,

 // properties: name, type, flags, notifyId, revision
      49, QMetaType::Int, 0x00015103, uint(0), 0,
      50, QMetaType::Bool, 0x00015103, uint(1), 0,
      51, 0x80000000 | 35, 0x00015009, uint(2), 0,

       0        // eod
};

Q_CONSTINIT const QMetaObject TaskController::staticMetaObject = { {
    QMetaObject::SuperData::link<QObject::staticMetaObject>(),
    qt_meta_stringdata_ZN14TaskControllerE.offsetsAndSizes,
    qt_meta_data_ZN14TaskControllerE,
    qt_static_metacall,
    nullptr,
    qt_incomplete_metaTypeArray<qt_meta_tag_ZN14TaskControllerE_t,
        // property 'currentProjectId'
        QtPrivate::TypeAndForceComplete<int, std::true_type>,
        // property 'loading'
        QtPrivate::TypeAndForceComplete<bool, std::true_type>,
        // property 'tasks'
        QtPrivate::TypeAndForceComplete<QVariantList, std::true_type>,
        // Q_OBJECT / Q_GADGET
        QtPrivate::TypeAndForceComplete<TaskController, std::true_type>,
        // method 'currentProjectIdChanged'
        QtPrivate::TypeAndForceComplete<void, std::false_type>,
        // method 'loadingChanged'
        QtPrivate::TypeAndForceComplete<void, std::false_type>,
        // method 'tasksChanged'
        QtPrivate::TypeAndForceComplete<void, std::false_type>,
        // method 'taskCreated'
        QtPrivate::TypeAndForceComplete<void, std::false_type>,
        QtPrivate::TypeAndForceComplete<int, std::false_type>,
        // method 'taskUpdated'
        QtPrivate::TypeAndForceComplete<void, std::false_type>,
        QtPrivate::TypeAndForceComplete<int, std::false_type>,
        // method 'taskDeleted'
        QtPrivate::TypeAndForceComplete<void, std::false_type>,
        QtPrivate::TypeAndForceComplete<int, std::false_type>,
        // method 'taskAssigned'
        QtPrivate::TypeAndForceComplete<void, std::false_type>,
        QtPrivate::TypeAndForceComplete<int, std::false_type>,
        QtPrivate::TypeAndForceComplete<int, std::false_type>,
        // method 'errorOccurred'
        QtPrivate::TypeAndForceComplete<void, std::false_type>,
        QtPrivate::TypeAndForceComplete<const QString &, std::false_type>,
        // method 'taskCreationFailed'
        QtPrivate::TypeAndForceComplete<void, std::false_type>,
        QtPrivate::TypeAndForceComplete<const QString &, std::false_type>,
        // method 'taskUpdateFailed'
        QtPrivate::TypeAndForceComplete<void, std::false_type>,
        QtPrivate::TypeAndForceComplete<const QString &, std::false_type>,
        // method 'taskDeletionFailed'
        QtPrivate::TypeAndForceComplete<void, std::false_type>,
        QtPrivate::TypeAndForceComplete<const QString &, std::false_type>,
        // method 'taskAssignmentFailed'
        QtPrivate::TypeAndForceComplete<void, std::false_type>,
        QtPrivate::TypeAndForceComplete<const QString &, std::false_type>,
        // method 'loadTasksForProject'
        QtPrivate::TypeAndForceComplete<void, std::false_type>,
        QtPrivate::TypeAndForceComplete<int, std::false_type>,
        // method 'loadTasksForCurrentProject'
        QtPrivate::TypeAndForceComplete<void, std::false_type>,
        // method 'createTask'
        QtPrivate::TypeAndForceComplete<bool, std::false_type>,
        QtPrivate::TypeAndForceComplete<int, std::false_type>,
        QtPrivate::TypeAndForceComplete<const QString &, std::false_type>,
        QtPrivate::TypeAndForceComplete<const QString &, std::false_type>,
        QtPrivate::TypeAndForceComplete<int, std::false_type>,
        QtPrivate::TypeAndForceComplete<int, std::false_type>,
        QtPrivate::TypeAndForceComplete<const int, std::false_type>,
        QtPrivate::TypeAndForceComplete<const QString &, std::false_type>,
        QtPrivate::TypeAndForceComplete<const QString &, std::false_type>,
        QtPrivate::TypeAndForceComplete<const QString &, std::false_type>,
        // method 'updateTask'
        QtPrivate::TypeAndForceComplete<bool, std::false_type>,
        QtPrivate::TypeAndForceComplete<int, std::false_type>,
        QtPrivate::TypeAndForceComplete<const QString &, std::false_type>,
        QtPrivate::TypeAndForceComplete<const QString &, std::false_type>,
        QtPrivate::TypeAndForceComplete<int, std::false_type>,
        QtPrivate::TypeAndForceComplete<const QString &, std::false_type>,
        QtPrivate::TypeAndForceComplete<const QString &, std::false_type>,
        QtPrivate::TypeAndForceComplete<const QString &, std::false_type>,
        QtPrivate::TypeAndForceComplete<const QString &, std::false_type>,
        // method 'deleteTask'
        QtPrivate::TypeAndForceComplete<bool, std::false_type>,
        QtPrivate::TypeAndForceComplete<int, std::false_type>,
        // method 'assignTask'
        QtPrivate::TypeAndForceComplete<bool, std::false_type>,
        QtPrivate::TypeAndForceComplete<int, std::false_type>,
        QtPrivate::TypeAndForceComplete<int, std::false_type>,
        // method 'getTaskDetails'
        QtPrivate::TypeAndForceComplete<QVariantMap, std::false_type>,
        QtPrivate::TypeAndForceComplete<int, std::false_type>,
        // method 'getSubTasks'
        QtPrivate::TypeAndForceComplete<QVariantList, std::false_type>,
        QtPrivate::TypeAndForceComplete<int, std::false_type>,
        // method 'createSubTask'
        QtPrivate::TypeAndForceComplete<bool, std::false_type>,
        QtPrivate::TypeAndForceComplete<int, std::false_type>,
        QtPrivate::TypeAndForceComplete<const QString &, std::false_type>,
        QtPrivate::TypeAndForceComplete<const QString &, std::false_type>,
        QtPrivate::TypeAndForceComplete<int, std::false_type>,
        QtPrivate::TypeAndForceComplete<const QString &, std::false_type>,
        QtPrivate::TypeAndForceComplete<const QString &, std::false_type>,
        // method 'deleteSubTask'
        QtPrivate::TypeAndForceComplete<bool, std::false_type>,
        QtPrivate::TypeAndForceComplete<int, std::false_type>,
        // method 'getTaskHierarchy'
        QtPrivate::TypeAndForceComplete<QVariantMap, std::false_type>,
        QtPrivate::TypeAndForceComplete<int, std::false_type>,
        // method 'getAvailableEmployees'
        QtPrivate::TypeAndForceComplete<QVariantList, std::false_type>,
        // method 'getDepartmentEmployees'
        QtPrivate::TypeAndForceComplete<QVariantList, std::false_type>,
        // method 'getTasksForProject'
        QtPrivate::TypeAndForceComplete<QVariantList, std::false_type>,
        QtPrivate::TypeAndForceComplete<int, std::false_type>,
        // method 'getCurrentUser'
        QtPrivate::TypeAndForceComplete<User *, std::false_type>,
        // method 'getTasksForProjectByStatus'
        QtPrivate::TypeAndForceComplete<QVariantList, std::false_type>,
        QtPrivate::TypeAndForceComplete<int, std::false_type>,
        QtPrivate::TypeAndForceComplete<const QString &, std::false_type>
    >,
    nullptr
} };

void TaskController::qt_static_metacall(QObject *_o, QMetaObject::Call _c, int _id, void **_a)
{
    auto *_t = static_cast<TaskController *>(_o);
    if (_c == QMetaObject::InvokeMetaMethod) {
        switch (_id) {
        case 0: _t->currentProjectIdChanged(); break;
        case 1: _t->loadingChanged(); break;
        case 2: _t->tasksChanged(); break;
        case 3: _t->taskCreated((*reinterpret_cast< std::add_pointer_t<int>>(_a[1]))); break;
        case 4: _t->taskUpdated((*reinterpret_cast< std::add_pointer_t<int>>(_a[1]))); break;
        case 5: _t->taskDeleted((*reinterpret_cast< std::add_pointer_t<int>>(_a[1]))); break;
        case 6: _t->taskAssigned((*reinterpret_cast< std::add_pointer_t<int>>(_a[1])),(*reinterpret_cast< std::add_pointer_t<int>>(_a[2]))); break;
        case 7: _t->errorOccurred((*reinterpret_cast< std::add_pointer_t<QString>>(_a[1]))); break;
        case 8: _t->taskCreationFailed((*reinterpret_cast< std::add_pointer_t<QString>>(_a[1]))); break;
        case 9: _t->taskUpdateFailed((*reinterpret_cast< std::add_pointer_t<QString>>(_a[1]))); break;
        case 10: _t->taskDeletionFailed((*reinterpret_cast< std::add_pointer_t<QString>>(_a[1]))); break;
        case 11: _t->taskAssignmentFailed((*reinterpret_cast< std::add_pointer_t<QString>>(_a[1]))); break;
        case 12: _t->loadTasksForProject((*reinterpret_cast< std::add_pointer_t<int>>(_a[1]))); break;
        case 13: _t->loadTasksForCurrentProject(); break;
        case 14: { bool _r = _t->createTask((*reinterpret_cast< std::add_pointer_t<int>>(_a[1])),(*reinterpret_cast< std::add_pointer_t<QString>>(_a[2])),(*reinterpret_cast< std::add_pointer_t<QString>>(_a[3])),(*reinterpret_cast< std::add_pointer_t<int>>(_a[4])),(*reinterpret_cast< std::add_pointer_t<int>>(_a[5])),(*reinterpret_cast< std::add_pointer_t<int>>(_a[6])),(*reinterpret_cast< std::add_pointer_t<QString>>(_a[7])),(*reinterpret_cast< std::add_pointer_t<QString>>(_a[8])),(*reinterpret_cast< std::add_pointer_t<QString>>(_a[9])));
            if (_a[0]) *reinterpret_cast< bool*>(_a[0]) = std::move(_r); }  break;
        case 15: { bool _r = _t->updateTask((*reinterpret_cast< std::add_pointer_t<int>>(_a[1])),(*reinterpret_cast< std::add_pointer_t<QString>>(_a[2])),(*reinterpret_cast< std::add_pointer_t<QString>>(_a[3])),(*reinterpret_cast< std::add_pointer_t<int>>(_a[4])),(*reinterpret_cast< std::add_pointer_t<QString>>(_a[5])),(*reinterpret_cast< std::add_pointer_t<QString>>(_a[6])),(*reinterpret_cast< std::add_pointer_t<QString>>(_a[7])),(*reinterpret_cast< std::add_pointer_t<QString>>(_a[8])));
            if (_a[0]) *reinterpret_cast< bool*>(_a[0]) = std::move(_r); }  break;
        case 16: { bool _r = _t->deleteTask((*reinterpret_cast< std::add_pointer_t<int>>(_a[1])));
            if (_a[0]) *reinterpret_cast< bool*>(_a[0]) = std::move(_r); }  break;
        case 17: { bool _r = _t->assignTask((*reinterpret_cast< std::add_pointer_t<int>>(_a[1])),(*reinterpret_cast< std::add_pointer_t<int>>(_a[2])));
            if (_a[0]) *reinterpret_cast< bool*>(_a[0]) = std::move(_r); }  break;
        case 18: { QVariantMap _r = _t->getTaskDetails((*reinterpret_cast< std::add_pointer_t<int>>(_a[1])));
            if (_a[0]) *reinterpret_cast< QVariantMap*>(_a[0]) = std::move(_r); }  break;
        case 19: { QVariantList _r = _t->getSubTasks((*reinterpret_cast< std::add_pointer_t<int>>(_a[1])));
            if (_a[0]) *reinterpret_cast< QVariantList*>(_a[0]) = std::move(_r); }  break;
        case 20: { bool _r = _t->createSubTask((*reinterpret_cast< std::add_pointer_t<int>>(_a[1])),(*reinterpret_cast< std::add_pointer_t<QString>>(_a[2])),(*reinterpret_cast< std::add_pointer_t<QString>>(_a[3])),(*reinterpret_cast< std::add_pointer_t<int>>(_a[4])),(*reinterpret_cast< std::add_pointer_t<QString>>(_a[5])),(*reinterpret_cast< std::add_pointer_t<QString>>(_a[6])));
            if (_a[0]) *reinterpret_cast< bool*>(_a[0]) = std::move(_r); }  break;
        case 21: { bool _r = _t->deleteSubTask((*reinterpret_cast< std::add_pointer_t<int>>(_a[1])));
            if (_a[0]) *reinterpret_cast< bool*>(_a[0]) = std::move(_r); }  break;
        case 22: { QVariantMap _r = _t->getTaskHierarchy((*reinterpret_cast< std::add_pointer_t<int>>(_a[1])));
            if (_a[0]) *reinterpret_cast< QVariantMap*>(_a[0]) = std::move(_r); }  break;
        case 23: { QVariantList _r = _t->getAvailableEmployees();
            if (_a[0]) *reinterpret_cast< QVariantList*>(_a[0]) = std::move(_r); }  break;
        case 24: { QVariantList _r = _t->getDepartmentEmployees();
            if (_a[0]) *reinterpret_cast< QVariantList*>(_a[0]) = std::move(_r); }  break;
        case 25: { QVariantList _r = _t->getTasksForProject((*reinterpret_cast< std::add_pointer_t<int>>(_a[1])));
            if (_a[0]) *reinterpret_cast< QVariantList*>(_a[0]) = std::move(_r); }  break;
        case 26: { User* _r = _t->getCurrentUser();
            if (_a[0]) *reinterpret_cast< User**>(_a[0]) = std::move(_r); }  break;
        case 27: { QVariantList _r = _t->getTasksForProjectByStatus((*reinterpret_cast< std::add_pointer_t<int>>(_a[1])),(*reinterpret_cast< std::add_pointer_t<QString>>(_a[2])));
            if (_a[0]) *reinterpret_cast< QVariantList*>(_a[0]) = std::move(_r); }  break;
        default: ;
        }
    }
    if (_c == QMetaObject::IndexOfMethod) {
        int *result = reinterpret_cast<int *>(_a[0]);
        {
            using _q_method_type = void (TaskController::*)();
            if (_q_method_type _q_method = &TaskController::currentProjectIdChanged; *reinterpret_cast<_q_method_type *>(_a[1]) == _q_method) {
                *result = 0;
                return;
            }
        }
        {
            using _q_method_type = void (TaskController::*)();
            if (_q_method_type _q_method = &TaskController::loadingChanged; *reinterpret_cast<_q_method_type *>(_a[1]) == _q_method) {
                *result = 1;
                return;
            }
        }
        {
            using _q_method_type = void (TaskController::*)();
            if (_q_method_type _q_method = &TaskController::tasksChanged; *reinterpret_cast<_q_method_type *>(_a[1]) == _q_method) {
                *result = 2;
                return;
            }
        }
        {
            using _q_method_type = void (TaskController::*)(int );
            if (_q_method_type _q_method = &TaskController::taskCreated; *reinterpret_cast<_q_method_type *>(_a[1]) == _q_method) {
                *result = 3;
                return;
            }
        }
        {
            using _q_method_type = void (TaskController::*)(int );
            if (_q_method_type _q_method = &TaskController::taskUpdated; *reinterpret_cast<_q_method_type *>(_a[1]) == _q_method) {
                *result = 4;
                return;
            }
        }
        {
            using _q_method_type = void (TaskController::*)(int );
            if (_q_method_type _q_method = &TaskController::taskDeleted; *reinterpret_cast<_q_method_type *>(_a[1]) == _q_method) {
                *result = 5;
                return;
            }
        }
        {
            using _q_method_type = void (TaskController::*)(int , int );
            if (_q_method_type _q_method = &TaskController::taskAssigned; *reinterpret_cast<_q_method_type *>(_a[1]) == _q_method) {
                *result = 6;
                return;
            }
        }
        {
            using _q_method_type = void (TaskController::*)(const QString & );
            if (_q_method_type _q_method = &TaskController::errorOccurred; *reinterpret_cast<_q_method_type *>(_a[1]) == _q_method) {
                *result = 7;
                return;
            }
        }
        {
            using _q_method_type = void (TaskController::*)(const QString & );
            if (_q_method_type _q_method = &TaskController::taskCreationFailed; *reinterpret_cast<_q_method_type *>(_a[1]) == _q_method) {
                *result = 8;
                return;
            }
        }
        {
            using _q_method_type = void (TaskController::*)(const QString & );
            if (_q_method_type _q_method = &TaskController::taskUpdateFailed; *reinterpret_cast<_q_method_type *>(_a[1]) == _q_method) {
                *result = 9;
                return;
            }
        }
        {
            using _q_method_type = void (TaskController::*)(const QString & );
            if (_q_method_type _q_method = &TaskController::taskDeletionFailed; *reinterpret_cast<_q_method_type *>(_a[1]) == _q_method) {
                *result = 10;
                return;
            }
        }
        {
            using _q_method_type = void (TaskController::*)(const QString & );
            if (_q_method_type _q_method = &TaskController::taskAssignmentFailed; *reinterpret_cast<_q_method_type *>(_a[1]) == _q_method) {
                *result = 11;
                return;
            }
        }
    }
    if (_c == QMetaObject::ReadProperty) {
        void *_v = _a[0];
        switch (_id) {
        case 0: *reinterpret_cast< int*>(_v) = _t->currentProjectId(); break;
        case 1: *reinterpret_cast< bool*>(_v) = _t->loading(); break;
        case 2: *reinterpret_cast< QVariantList*>(_v) = _t->tasks(); break;
        default: break;
        }
    }
    if (_c == QMetaObject::WriteProperty) {
        void *_v = _a[0];
        switch (_id) {
        case 0: _t->setCurrentProjectId(*reinterpret_cast< int*>(_v)); break;
        case 1: _t->setLoading(*reinterpret_cast< bool*>(_v)); break;
        default: break;
        }
    }
}

const QMetaObject *TaskController::metaObject() const
{
    return QObject::d_ptr->metaObject ? QObject::d_ptr->dynamicMetaObject() : &staticMetaObject;
}

void *TaskController::qt_metacast(const char *_clname)
{
    if (!_clname) return nullptr;
    if (!strcmp(_clname, qt_meta_stringdata_ZN14TaskControllerE.stringdata0))
        return static_cast<void*>(this);
    return QObject::qt_metacast(_clname);
}

int TaskController::qt_metacall(QMetaObject::Call _c, int _id, void **_a)
{
    _id = QObject::qt_metacall(_c, _id, _a);
    if (_id < 0)
        return _id;
    if (_c == QMetaObject::InvokeMetaMethod) {
        if (_id < 28)
            qt_static_metacall(this, _c, _id, _a);
        _id -= 28;
    }
    if (_c == QMetaObject::RegisterMethodArgumentMetaType) {
        if (_id < 28)
            *reinterpret_cast<QMetaType *>(_a[0]) = QMetaType();
        _id -= 28;
    }
    if (_c == QMetaObject::ReadProperty || _c == QMetaObject::WriteProperty
            || _c == QMetaObject::ResetProperty || _c == QMetaObject::BindableProperty
            || _c == QMetaObject::RegisterPropertyMetaType) {
        qt_static_metacall(this, _c, _id, _a);
        _id -= 3;
    }
    return _id;
}

// SIGNAL 0
void TaskController::currentProjectIdChanged()
{
    QMetaObject::activate(this, &staticMetaObject, 0, nullptr);
}

// SIGNAL 1
void TaskController::loadingChanged()
{
    QMetaObject::activate(this, &staticMetaObject, 1, nullptr);
}

// SIGNAL 2
void TaskController::tasksChanged()
{
    QMetaObject::activate(this, &staticMetaObject, 2, nullptr);
}

// SIGNAL 3
void TaskController::taskCreated(int _t1)
{
    void *_a[] = { nullptr, const_cast<void*>(reinterpret_cast<const void*>(std::addressof(_t1))) };
    QMetaObject::activate(this, &staticMetaObject, 3, _a);
}

// SIGNAL 4
void TaskController::taskUpdated(int _t1)
{
    void *_a[] = { nullptr, const_cast<void*>(reinterpret_cast<const void*>(std::addressof(_t1))) };
    QMetaObject::activate(this, &staticMetaObject, 4, _a);
}

// SIGNAL 5
void TaskController::taskDeleted(int _t1)
{
    void *_a[] = { nullptr, const_cast<void*>(reinterpret_cast<const void*>(std::addressof(_t1))) };
    QMetaObject::activate(this, &staticMetaObject, 5, _a);
}

// SIGNAL 6
void TaskController::taskAssigned(int _t1, int _t2)
{
    void *_a[] = { nullptr, const_cast<void*>(reinterpret_cast<const void*>(std::addressof(_t1))), const_cast<void*>(reinterpret_cast<const void*>(std::addressof(_t2))) };
    QMetaObject::activate(this, &staticMetaObject, 6, _a);
}

// SIGNAL 7
void TaskController::errorOccurred(const QString & _t1)
{
    void *_a[] = { nullptr, const_cast<void*>(reinterpret_cast<const void*>(std::addressof(_t1))) };
    QMetaObject::activate(this, &staticMetaObject, 7, _a);
}

// SIGNAL 8
void TaskController::taskCreationFailed(const QString & _t1)
{
    void *_a[] = { nullptr, const_cast<void*>(reinterpret_cast<const void*>(std::addressof(_t1))) };
    QMetaObject::activate(this, &staticMetaObject, 8, _a);
}

// SIGNAL 9
void TaskController::taskUpdateFailed(const QString & _t1)
{
    void *_a[] = { nullptr, const_cast<void*>(reinterpret_cast<const void*>(std::addressof(_t1))) };
    QMetaObject::activate(this, &staticMetaObject, 9, _a);
}

// SIGNAL 10
void TaskController::taskDeletionFailed(const QString & _t1)
{
    void *_a[] = { nullptr, const_cast<void*>(reinterpret_cast<const void*>(std::addressof(_t1))) };
    QMetaObject::activate(this, &staticMetaObject, 10, _a);
}

// SIGNAL 11
void TaskController::taskAssignmentFailed(const QString & _t1)
{
    void *_a[] = { nullptr, const_cast<void*>(reinterpret_cast<const void*>(std::addressof(_t1))) };
    QMetaObject::activate(this, &staticMetaObject, 11, _a);
}
QT_WARNING_POP
